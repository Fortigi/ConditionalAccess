function Remove-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The Remove-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to remove an existing Conditional Access Policy, using an ID as input for the targeted policy. 
    
    .Description
        The command removes an existing Conditional Access Policy Based on the ID of the Policy 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.ReadWrite.ConditionalAccess
        RoleManagement.Read.Directory

    - An existing policy to delete 
        Policy ID required for this command can be found using the "Get-ConditionalAccessPolicy" command
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