function Get-ConditionalAccessPolicyFile {
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [Parameter(Mandatory = $true)]
        $DisplayName,
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $false)]
        $All, 
        [Parameter(Mandatory = $false)]
        $Id 
    )
    
    [Array]$Policies = Get-ConditionalAccessPolicy -DisplayName $DisplayName -AccessToken $AccessToken -All $All -Id $Id


    $Policy.conditions.applications.includeApplications | ConvertTo-Json | Out-file ($Path + "\" + $DisplayName + ".json")
}