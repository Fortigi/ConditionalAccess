

[array]$NewRoleObject = $null

$URI = "https://graph.microsoft.com/beta/directoryRoles"
$RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
[array]$RolesFromGraph = $RoleObject.value
Foreach ($RoleFromGraph in $RolesFromGraph){
$Roles = New-object psobject
$roles | add-member noteproperty ObjectID           $RoleFromGraph.Id
$roles | add-member NoteProperty DisplayName        $RoleFromGraph.DisplayName
$NewRoleObject += $Roles   
}

$NewRoleObject | ConvertTo-Json