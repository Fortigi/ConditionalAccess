function Get-ConditionalAccessPolicyFile {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $accessToken,
        [Parameter(Mandatory = $true)]
        $DisplayName,
        [Parameter(Mandatory = $true)]
        $Path
    )
    
    $Policy = Get-ConditionalAccessPolicy -DisplayName $DisplayName -accessToken $accessToken
    $Policy | ConvertTo-Json | Out-file ($Path + "\" + $DisplayName + ".json")
}