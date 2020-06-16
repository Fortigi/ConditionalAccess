function ConvertFrom-ApplicationDisplayNameToGUID {
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$UserUPNs,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )

    $ApplicationDisplayNames = $PolicyPs.conditions.applications.includeApplications

    [array]$UserGuids = $null

    if ($ApplicationDisplayNames -ne "All" -or "all") {
        foreach ($ApplicationDisplayName in $ApplicationDisplayNames) {
            $URI = "https://graph.microsoft.com/beta/ServicePrincipals?" + '$filter' + "=displayName eq '$ApplicationDisplayName'"
            $ApplicationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$ApplicationObject.value[5]) {
                throw "User-object could not be found in AzureAD through Microsoft Graph for the displayname: $UserUPN. Check the spelling of the UPN and verify the existince of the user in the specified Tenant"
            }  
            $ApplicationGuids += ($ApplicationObject.value.id)
        }
    }
    Return $ApplicationGuids
}