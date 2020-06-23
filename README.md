# ConditionalAccess

This solution consists of powershell functions, bundled in a module to help automate and regulate Conditional Access deployment and maintance.

## The module 
The module consists of several public functions and several private functions, or sub-functions. 

### The public functions are:
- Get-AccessToken                 (to retrieve an access token used for accessing Microsoft Graph)
- Get-ConditionalAccessPolicy     (to retrieve one or multiple Conditional Access Policies)
- Get-ConditionalAcessPolicyFile  (to retrieve one or multiple Conditional Access Policies with a .Json file as output
- New-ConditionalAccessPolicy     (to create a new Conditional Access Policy using a .Json file as input)
- Remove-ConditionalAccessPolicy  (to remove an existing Conditional Access Policy)
- Set-ConditionalAccessPolicy     (to update an existing Conditional Access Policy)

To be in control over Conditional Access and to be able to apply efficient and effective version control it is important that the .Json representation of the policies is readable by the people maintaining them. Since Microsoft Graph can only process GUIDs in .Json format when creating or updating Policies the issu surfaced that Microsoft Graph and the people maintaining the policies need different versions of the policy files. 
To achieve this, the module contains several private function.

### The private functions are:
- ConvertFrom-ApplicationDisplayNametoGUID
- ConvertFrom-GroupDisplayNametoGUID
- ConvertFrom-RoleDisplayNametoGUID
- ConvertFrom-UserUserPrinicpleNameToGUID

The private functions convert the human-readable DisplayNames (and UserPrincipalNames) that are stated in the policy files to their respective GUIDs in the target AzureAD tenant. The private functions are sub-functions to the public functions, meaning all the conversions happen in the background. 


## Getting Started
### Licensing 
To use the functions that actually change the policies in your tenant, you need at least an AzureAD premium P1 license.
For Risk Based Conditional Access Policies you will need an AzureAD premium p2 license.

### Start with the demo
1. Download or clone the repository 
2. Open .\Examples\Script\Demo.ps1

3. Go to your Azure tenant and create a new "App Registration"
4. Fill in a DisplayName of your choice, and choose the "Single tenant" option
5. Go to the Authentication tab and "Add a Platform". pick the Native Client option: "https://login.microsoftonline.com/common/oauth2/nativeclient" 
and choose "Yes" for default Client Type 
6. Under API Permissions add the following permissions:
- User.Read.All
- Application.Read.All
- Group.Read.All
- Policy.Read.All
- Policy.ReadWrite.ConditionalAccess
- RoleManagement.Read.Directory
-Optional permission for automatic group creation:  
    Group.Create
7. Go to the "Certificates & secrets" Tab and create a new Secret. Be sure to save secret somewhere. 
8. In the "Overview" of the App Registration, look for the ClientID and the Directory (tenant)ID.
9. Go back to .\Examples\Script\Demo.ps1 fill in the variables: $ClientID, $TenantID and $ClientSecret with the information from the steps above. 
10. Run the Import-Module .\ConditionalAccess\ConditionalAccess.psm1 command to import the module
11. run $AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret to obtain an Access Token
12. Open the desired Policy .Json file of your choice and adjust the content so that the displayNames in the $File match existing DisplayNames in the Targeted Tenant. The Users in the examples will most likely not exist in your tenant and probably need to be adjusted. 
13. After loading a valid Json in $File you can run the commands you want for the demo 

You can use 
$ca = Get-ConditionalAccessPolicy -accessToken $AccessToken -DisplayName "CA-01- All Apps - All Admins - Require MFA"
To dissect the content of the created or existing Policy of your choice. e.g. you can run:
$ca.conditions.users.includeRoles 
To see that the "All" in the example policy was succesfully translated to a large number of GUIDs of RoleTemplates in the target Tenant. 
Since $ca gets it information directly from Graph you will see the GUIDs via this way. 

We might create a reversed conversion in the nearby future.  








