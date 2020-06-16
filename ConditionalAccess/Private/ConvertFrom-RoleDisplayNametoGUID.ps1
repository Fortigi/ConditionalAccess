function ConvertFrom-RoleDisplayNametoGUID { 
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$RoleDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    
    [array]$RoleGuids = $null
    
    $RoleDisplayNames = $PolicyPs.conditions.users.includeRoles
    
    foreach ($RoleDisplayName in $RoleDisplayNames) {
        $URI = "https://graph.microsoft.com/beta/directoryRoles?" + '$filter' + "=displayName eq '$RoleDisplayName'"
        $RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
        If (!$RoleObject.value) {
            throw "Role-object could not be found in AzureAD through Microsoft Graph for the displayname: $RoleDisplayName. Check the spelling of the Role and verify the existince of the Role in the specified Tenant"
        }  
        $RoleGuids += ($RoleObject.value.id)
    }
    Return $RoleGuids
}
