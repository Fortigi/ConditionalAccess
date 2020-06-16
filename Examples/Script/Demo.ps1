
#Run
Remove-Module ConditionalAccess
Import-Module C:\Source\GitHub\Fortigi\ConditionalAccess\ConditionalAccess\ConditionalAccess.psm1


$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

#Get Existing Policies.. in Json Format
$Polciies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -All $true

#Upload a new policy
$File = 'C:\Source\GitHub\Fortigi\ConditionalAccess\Examples\Policy\CA-01- All Apps - All Admins - Require MFA.json.json'
#New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File

New-ConditionalAccessPolicy -accessToken $AccessToken -PolicyFile $File -Force $True

