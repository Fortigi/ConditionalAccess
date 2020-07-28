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

$TenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$ClientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$ClientSecret = "aA_aAaa12A1A1aaAa_a~aAA_1A-AAaaaaaaa" 

$AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret


################################################################################################################################
#Example 1; Download existing Conditional Access Policies
################################################################################################################################

#Get Existing Policies.. in Json Format
$Policies = Get-ConditionalAccessPolicy -AccessToken $AccessToken

#Export existing policies to JSON files
Get-ConditionalAccessPolicyFile -AccessToken $AccessToken -Path .\Examples\Policy\Temp


################################################################################################################################
#Example 2; Upload policy
################################################################################################################################

#Upload a new policy, Be sure to adjust the demo file with the correct displayNames to avoid errors. 
$File = ".\Examples\Policy\CA-01- All Apps - All Admins - Require MFA.json"
New-ConditionalAccessPolicy -AccessToken $AccessToken -PolicyFile $File



























