#Prerequisites a ClientID + ClientSecret with the minimum following API permissions:
#    User.Read.All
#    Application.Read.All
#    Group.Read.All
#    Policy.Read.All
#    Policy.ReadWrite.ConditionalAccess
#    RoleManagement.Read.Directory

#    -Optional permission for automatic group creation 
#    Group.Create

################################################################################################################################
#Load module and get access token
################################################################################################################################

Import-Module .\ConditionalAccess\ConditionalAccess.psm1 -Force


#PorIAMDEV
$TargetTenantName = "xxxxx.onmicrosoft.com"
$TenantId = "xxxxxxx"
$ClientId = "xxxxxxxx"
$ClientSecret = "xxxxxxxxx"


$PathConvertFile = ".\Examples\Policy\Convert.Json"
$PolicyFileLocation = ".\Examples\Policy\Policies"

#Get Policies from Azure
$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret
Get-ConditionalAccessPolicyFile -AccessToken $AccessToken -Path $PolicyFileLocation -PathConvertFile $PathConvertFile 

#Deploy Policies to Azure
Deploy-ConditionalAccessPolicies -TargetTenantName $TargetTenantName `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientSecret $ClientSecret `
    -PolicyFileLocation $PolicyFileLocation `
    -PathConvertFile $PathConvertFile `
    -TestOnly $true `
    -Overwrite $true `
    -RemoveExisting $true












