function Get-ConditionalAccessPolicy {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $accessToken,
        [Parameter(Mandatory = $false)]
        $All, 
        [Parameter(Mandatory = $false)]
        $DisplayName,
        [Parameter(Mandatory = $false)]
        $Id 
    )
    if ($DisplayName) {
        #$conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=displayName eq '$DisplayName'"
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=endswith(displayName, '$DisplayName')"
    }
    if ($Id) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
    }
    if ($All -eq $true) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"
    }
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Get -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $accessToken" }
    $conditionalAccessPolicyResponse.value    
}