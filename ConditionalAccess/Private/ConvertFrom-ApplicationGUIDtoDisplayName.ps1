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
            "office365" {
                $DontSearchGraph += 1
                $ApplicationDisplayNames += "Office 365"; Break
                
            }
            "all" {
                $DontSearchGraph += 1
                $ApplicationGuids = $null
                $ApplicationDisplayNames += "All"; Break
            }
            "797f4846-ba00-4fd7-ba43-dac1f8f63013" {
                $DontSearchGraph += 1
                $ApplicationDisplayNames += "Microsoft Azure Management"; Break
            }
        }

        If (!$DontSearchGraph){
            $URI = "https://graph.microsoft.com/beta/ServicePrincipals?" + '$filter' + "=appId eq '$ApplicationGuid'"
            $ApplicationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            
            #$URI = "https://graph.microsoft.com/beta/ServicePrincipals"
            #$ApplicationObjects = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            #$ApplicationObject = $ApplicationObjects | Where-Object {$_.appId -eq $ApplicationGuid}

            If (!$ApplicationObject.value) {
                Throw "Application: $ApplicationGuid specified in policy was not found."
            }  
            $ApplicationDisplayNames += ($ApplicationObject.value.displayName)
        }
    }
    Return $ApplicationDisplayNames
}

