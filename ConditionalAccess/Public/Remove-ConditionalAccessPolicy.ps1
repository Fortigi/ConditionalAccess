function Remove-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The Remove-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to remove an existing Conditional Access Policy, using an ID as input for the targeted policy. 
    
    .Description
        The command removes and eisting 

    In order to allow for more flexibility rolling out the exact same JSONS to different Tenants while maintaining the readability of the JSON policy files:
    - The "DisplayNames" of "Groups" and "Applications" are automatically translated to their respective ObjectIDs (GUIDs) as they are found in the targeted Tenant in the background. 
    - The "UserPrincipalNames" of "Users" are automatically translated to their respective ObjectIDs (GUIDs) as they are found the targeted Tenant in the background.

    The -Force Paramter can be added to automatically create "Groups" based on the displayNames found in the JSON if no correlating "Groups" are found in the target tenant.  

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.ReadWrite.ConditionalAccess
        The Command automatically converts existing DisplayNames from the JSON to their ObjectIDs (GUIDs) in the targeted Tenant. 

        -Optional permission for automatic group creation 
        Group.Create
    #>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Id,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Delete -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $accessToken" }
    $conditionalAccessPolicyResponse     
}