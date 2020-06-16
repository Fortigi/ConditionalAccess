function ConvertFrom-UserUserPrinicpleNameToGUID {
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$UserUPNs,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )

    $UserUPNs = $PolicyPs.conditions.users.includeUsers

    [array]$UserGuids = $null

    if ($UserUPNs -ne "All" -or "all") {
        foreach ($UserUPN in $UserUPNs) {
            $URI = "https://graph.microsoft.com/beta/users?" + '$filter' + "=userPrincipalName eq '$UserUPN'"
            $UserObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$UserObject.value) {
                throw "User-object could not be found in AzureAD through Microsoft Graph for the displayname: $UserUPN. Check the spelling of the UPN and verify the existince of the user in the specified Tenant"
            }  
            $UserGuids += ($UserObject.value.id)
        }
    }
    Return $UserGuids
}