function Get-ConditionalAccessPolicy {
        <#
    .SYNOPSIS
    The Get-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to get some or all of the Conditional Access policies in the targeted AzureAD tenant.
    
    .Description
    Prerequisites
    - App registered in the target Azure Active Directory
    - Valid client secret of the App
    - The App needs to have at least the followwing Admin Consented API permissions to be used for Conditional Access policies*:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.Read.ConditionalAccess

    .example 
    #Example to get All policies
    Get-ConditionalAccessPolicy -AccessToken $AccessToken -All $True

    #Example to get a specIfic policy based on DisplayName
    $ConditionalAccessPolicyDisplayName = "CA-01- All Apps - All Admins - Require MFA"
    Get-ConditionalAccessPolicy -AccessToken $AccessToken -DisplayName $ConditionalAccessPolicyDisplayName
    #>
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [Parameter(Mandatory = $false)]
        $All, 
        [Parameter(Mandatory = $false)]
        $DisplayName,
        [Parameter(Mandatory = $false)]
        $Id 
    )
    If ($DisplayName) {
        #$conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=displayName eq '$DisplayName'"
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=endswith(displayName, '$DisplayName')"
    }
    If ($Id) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
    }
    If ($All -eq $true) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"
    }
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Get -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $AccessToken" }
    $conditionalAccessPolicyResponse.value    
}