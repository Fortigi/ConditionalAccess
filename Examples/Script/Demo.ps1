
#Run
#Remove-Module ConditionalAccess
Import-Module C:\Source\VSTS\GitHub\ConditionalAccess\ConditionalAccess\ConditionalAccess.psm1

$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

#Get Existing Policies.. in Json Format
# Policies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -All $true

#Upload a new policy
$File = 'C:\Source\VSTS\GitHub\ConditionalAccess\Examples\Policy\CA-02- All Apps - All Users - Require MFA or Trusted Device.json'
#New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File

Get-ConditionalAccessPolicy -accessToken $AccessToken -all $true
New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File -Force $True 
Get-ConditionalAccessPolicy -accessToken $AccessToken -DisplayName "CA-02- All Apps - All Users - Require MFA or Trusted Device"

