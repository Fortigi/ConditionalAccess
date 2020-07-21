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
    [Array]$InclusionApplicationDisplayNames = $null
    [Array]$ExclusionApplicationDisplayNames = $null


    Foreach ($policy in $Policies){
    [array]$InclusionApplicationDisplayNames += ConvertFrom-ApplicationGUIDToDisplayName -ApplicationGuids ($policy.conditions.applications.includeApplications) -AccessToken $AccessToken 
    [array]$ExclusionApplicationDisplayNames += ConvertFrom-ApplicationGUIDToDisplayName -ApplicationGuids ($policy.conditions.applications.excludeApplications) -AccessToken $AccessToken 
    If ($InclusionApplicationDisplayNames){ 
        $policy.conditions.applications.includeApplications = $InclusionApplicationDisplayNames
        }
    If ($ExclusionApplicationDisplayNames){ 
        $policy.conditions.applications.excludeApplications = $ExclusionApplicationDisplayNames
    }
}

    $Policy.conditions.applications.includeApplications | ConvertTo-Json | Out-file ($Path + "\" + $DisplayName + ".json")
}