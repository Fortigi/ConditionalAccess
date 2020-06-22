#Prerequisites a ClientID + ClientSecret with the minimum following API permissions:
#    User.Read.All
#    Application.Read.All
#    Group.Read.All
#    Policy.Read.All
#    Policy.ReadWrite.ConditionalAccess
#    RoleManagement.Read.Directory

#    -Optional permission for automatic group creation 
#    Group.Create

Import-Module .\ConditionalAccess\ConditionalAccess.psm1
#Remove-Module ConditionalAccess

$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

#Get Existing Policies.. in Json Format
# Policies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -All $true

#Upload a new policy, Be sure to adjust the demo file with the correct displayNames to avoid errors. 
$File = ".\Examples\Policy\CA-01- All Apps - All Admins - Require MFA.json"
#New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File

Get-ConditionalAccessPolicy -accessToken $AccessToken -all $true
New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File -Force $True 
Get-ConditionalAccessPolicy -accessToken $AccessToken -DisplayName "CA-01- All Apps - All Admins - Require MFA"
$ca = Get-ConditionalAccessPolicy -accessToken $AccessToken -DisplayName "CA-01- All Apps - All Admins - Require MFA"
$ca.conditions.users.includeRoles
