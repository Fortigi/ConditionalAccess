#Prerequisites a ClientID + ClientSecret with the minimum following API permissions:
#    User.Read.All
#    Application.Read.All
#    Group.Read.All
#    Policy.Read.All
#    Policy.ReadWrite.ConditionalAccess
#    RoleManagement.Read.Directory

#    -Optional permission for automatic group creation 
#    Group.Create


Import-Module .\ConditionalAccess\ConditionalAccess.psm1 -Force

#$TenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#$ClientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#$ClientSecret = "aA_aAaa12A1A1aaAa_a~aAA_1A-AAaaaaaaa" 

$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

#Get Existing Policies.. in Json Format
# Policies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -All $true

<#
#Upload a new policy, Be sure to adjust the demo file with the correct displayNames to avoid errors. 
$File = ".\Examples\Policy\CA-01- All Apps - All Admins - Require MFA.json"
#New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File

Get-ConditionalAccessPolicy -accessToken $AccessToken -All $true
New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File -CreateMissingGroups $true
$ca = Get-ConditionalAccessPolicy -accessToken $AccessToken -DisplayName "CA-HBRTEST05 - Azure management - All Users - Require trusted location"
$ca.conditions.applications.includeApplications

Remove-ConditionalAccessPolicy -Id "9ff72528-ca35-4852-a81f-4125db958e88" -AccessToken $AccessToken
#>

#Get-ConditionalAccessPolicy -accessToken $AccessToken

Get-ConditionalAccessPolicyFile -AccessToken $AccessToken -Path ".\Examples\Policy\A" #-ConvertGUIDs $False































