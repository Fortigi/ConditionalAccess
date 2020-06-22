function ConvertFrom-RoleDisplayNametoGUID { 
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$RoleDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    
    [array]$RoleGuids = $null

    $URI = "https://graph.microsoft.com/beta/directoryRoletemplates"
    $RoleTemplates = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
    [array]$Roles = $Roletemplates.value

    foreach ($RoleDisplayName in $RoleDisplayNames) {

        #Find role in Default roles set.
        $Found = $Roles | Where-Object { $_.DisplayName -eq $RoleDisplayName }

        If ($Found) {
            $RoleGuids += ($Found.Id) 
        }
        Else {
            $URI = "https://graph.microsoft.com/beta/directoryRoles?" + '$filter' + "=displayName eq '$RoleDisplayName'"
            $RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$RoleObject.value) {
                throw "Role $RoleDisplayName is not found."
            }
            $RoleGuids += ($RoleObject.value.id) 
        } 
        
    }
    Return $RoleGuids
}
