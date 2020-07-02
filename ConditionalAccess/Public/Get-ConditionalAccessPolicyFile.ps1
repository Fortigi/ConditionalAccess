function Get-ConditionalAccessPolicyFile {
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [Parameter(Mandatory = $true)]
        $DisplayName,
        [Parameter(Mandatory = $true)]
        $Path
    )
    
    $Policy = Get-ConditionalAccessPolicy -DisplayName $DisplayName -AccessToken $AccessToken
    $Policy | ConvertTo-Json | Out-file ($Path + "\" + $DisplayName + ".json")
}