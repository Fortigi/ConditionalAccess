function ConvertFrom-ApplicationDisplayNameToGUID {
    <#
    .SYNOPSIS
    The ConvertFrom-ApplicationDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of applications to their respective GUIDs as they exist in the targeted AzureAD tenant. 
    
    .Description
        The command takes the array of displaynames of applications from the JSON file and checks their existence in the targeted AzureAD tenant. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Application.Read.All

    .Example 
    [array]$YourApplicatioName = "ApplicationY"
    ConvertFrom-ApplicationDisplayNameToGUID -ApplicationDisplayNames $ApplicationY -AccessToken $AccessToken
    #>
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$ApplicationDisplayNames,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )

    [array]$ApplicationGuids = $null

    #$ApplicationDisplayNames = "Microsoft Azure Management"

    Foreach ($ApplicationDisplayName In $ApplicationDisplayNames) {
        $DontSearchGraph = $null

        Switch ($ApplicationDisplayName.ToString().ToLower()){
            #"Office365" is the represetation of the "Office 365 (preview)" Object in the GUI for Conditional Access through the Azure Portal. Static Converted is required as no object exists in the directory.
            "office 365" {
                $DontSearchGraph += 1
                $ApplicationGuids += "Office365"; Break
                
            }
            #"All" is the represetation all Apps both in and outside of the directory. Static Converted is required as no (single) object exists in the directory.
            "all" {
                $DontSearchGraph += 1
                $ApplicationGuids = $null
                $ApplicationGuids += "All"; Break
            }
            #The GUID for "Microsoft Azure Management" as found in the GUI for Conditional Access through the Azure Portal does not exist in the Directory, as it contains several applications and portals in one. Static Converted is necessary.
            "microsoft azure management" {
                $DontSearchGraph += 1
                $ApplicationGuids += "797f4846-ba00-4fd7-ba43-dac1f8f63013"; Break
            }
        }
        #If none of the staticly Converted GUIDs are triggered, search in Graph. 
        If (!$DontSearchGraph){
            $URI = "https://graph.microsoft.com/beta/ServicePrincipals?" + '$filter' + "=displayName eq '$ApplicationDisplayName'"
            $ApplicationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" }
            Start-Sleep -Seconds 1
            
            If (!$ApplicationObject.value) {
                Throw "Application: $ApplicationDisplayName specified in policy was not found."
            }  
            $ApplicationGuids += ($ApplicationObject.value.appId)
        }
    }
    Return $ApplicationGuids
}

