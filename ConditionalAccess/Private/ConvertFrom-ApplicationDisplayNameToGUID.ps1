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
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$ApplicationDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )

    [array]$ApplicationGuids = $null

    foreach ($ApplicationDisplayName in $ApplicationDisplayNames) {
        
        if ($ApplicationDisplayName.ToString().ToLower() -ne "all") {
            $URI = "https://graph.microsoft.com/beta/ServicePrincipals?" + '$filter' + "=displayName eq '$ApplicationDisplayName'"
            $ApplicationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$ApplicationObject.value) {
                throw "Application: $ApplicationDisplayName specified in policy was not found."
            }  
            $ApplicationGuids += ($ApplicationObject.value.id)
        }
        else {
            $ApplicationGuids = $null
            $ApplicationGuids += "All"
        }
    }
    Return $ApplicationGuids
}