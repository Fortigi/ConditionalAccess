function ConvertFrom-UserUserPrinicpleNameToGUID {
          <#
    .SYNOPSIS
    The ConvertFrom-UserUserPrinicpleNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]UserPrincipalNames of Users to their GUIDs as they exist in the targeted Tenant. 
    
    .Description
          
    .Description
        The command takes the array of UserPrincipalNames of Users from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the UserPrincipalName Exists the GUID is returned
        And added to the UserGUIDs array. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Users.Read.All


    .Example 
    [array]$UserUserPrincipalNames = "william@fortigi.nl"
    ConvertFrom-UserUserPrincipleNameGUID -UserUserPrincipalNames $UserUserPrincipalNames -AccessToken $AccessToken
    #>
    
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