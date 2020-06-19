function ConvertFrom-UserUserPrinicpleNameToGUID {
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$UserUserPrincipalNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    
    [array]$UserGuids = $null

    foreach ($UserUPN in $UserUserPrincipalNames) {

        if ($UserUPN.ToString().ToLower() -ne "all") {
            $URI = "https://graph.microsoft.com/beta/users?" + '$filter' + "=userPrincipalName eq '$UserUPN'"
            $UserObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$UserObject.value) {
                throw "User: $UserUPN specified in the Policy was not found in the directory. Create user, or update your policy."
            }  
            $UserGuids += ($UserObject.value.id)
        }
    else {
        $UserGuids = $null
        $UserGuids += "All"
    }
}
    Return $UserGuids
}