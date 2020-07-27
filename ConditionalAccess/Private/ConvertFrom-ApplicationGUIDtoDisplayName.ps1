function ConvertFrom-ApplicationGUIDToDIsplayName {
    <#
    .SYNOPSIS
    The ConvertFrom-ApplicationGUIDToDIsplayName command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of applications to their respective GUIDs as they exist in the targeted AzureAD tenant. 
    
    .Description
        The command takes the array of displaynames of applications from the JSON file and checks their existence in the targeted AzureAD tenant. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Application.Read.All

    .Example 
    [array]$YourApplicatioName = "ApplicationY"
    ConvertFrom-ApplicationGUIDToDIsplayName -ApplicationDisplayNames $ApplicationY -AccessToken $AccessToken
    #>
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$ApplicationGUIDs,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )

    [array]$ApplicationDisplayNames = $null

    #$ApplicationDisplayNames = "Microsoft Azure Management"

    Foreach ($ApplicationGuid In $ApplicationGuids) {
        $DontSearchGraph = $null

        Switch ($ApplicationGuid.ToString().ToLower()){
            #"Office365" is the represetation of the "Office 365 (preview)" Object in the GUI for Conditional Access through the Azure Portal. Static Converted is required as no object exists in the directory.            
            "office365" {
                $DontSearchGraph += 1
                $ApplicationDisplayNames += "Office 365"; Break
                
            }
            #"All" is the represetation all Apps both in and outside of the directory. Static Converted is required as no (single) object exists in the directory.
            "all" {
                $DontSearchGraph += 1
                $ApplicationGuids = $null
                $ApplicationDisplayNames += "All"; Break
            }
            #The GUID for "Microsoft Azure Management" as found in the GUI for Conditional Access through the Azure Portal does not exist in the Directory, as it contains several applications and portals in one. Static Converted is necessary.
            "797f4846-ba00-4fd7-ba43-dac1f8f63013" {
                $DontSearchGraph += 1
                $ApplicationDisplayNames += "Microsoft Azure Management"; Break
            }
        }
        #If none of the staticly Converted GUIDs are triggered, search in Graph.
        If (!$DontSearchGraph){
            $URI = "https://graph.microsoft.com/beta/ServicePrincipals?" + '$filter' + "=appId eq '$ApplicationGuid'"
            $ApplicationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            
            If (!$ApplicationObject.value) {
                Throw "Application: $ApplicationGuid specified in policy was not found."
            }  
            $ApplicationDisplayNames += ($ApplicationObject.value.displayName)
        }
    }
    Return $ApplicationDisplayNames
}

