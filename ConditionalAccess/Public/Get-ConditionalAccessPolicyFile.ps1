function Get-ConditionalAccessPolicyFile {
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $false)]
        $Id = $false,
        [Parameter(Mandatory = $false)]
        $DisplayName = $false,
        [Parameter(Mandatory = $false)]
        $ConvertGUIDs = $true
        
    )
    
    [Array]$Policies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -DisplayName $DisplayName -Id $Id -ConvertGUIDs $ConvertGUIDs

    Foreach ($Policy in $Policies) {
        
        #Check for characters that can't be used in filenames
        $FileName = ($Policy.displayName + ".json").Replace(":","").Replace("\","").Replace("*","").Replace("<","").Replace(">","")
        $Json = $Policy | ConvertTo-Json -Depth 3
        $Json | Out-file ($Path + "\" + $FileName)
        }
}