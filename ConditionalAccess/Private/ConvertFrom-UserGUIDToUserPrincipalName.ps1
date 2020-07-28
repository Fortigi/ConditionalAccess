function ConvertFrom-UserGUIDToUserPrincipalName {
          <#
    .SYNOPSIS
    The ConvertFrom-UserGUIDToUserPrincipalName command uses a Token from the "Get-AccessToken" command to convert the [array]UserGuids of Users to their UserPrincipalNames as they exist in the targeted Tenant. 
    
    .Description
          
    .Description
        The command takes the array of UserPrincipalNames of Users from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the UserPrincipalName Exists the GUID is returned
        And added to the UserGUIDs array. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Users.Read.All


    .Example 
    [array]$UserGuids = "william@fortigi.nl"
    ConvertFrom-UserGUIDToUserPrincipalName -UserGuids $UserGuids -AccessToken $AccessToken
    #>
    
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$UserGuids,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )
    
    [array]$UserUserPrincipalNames = $null

    Foreach ($Userguid in $UserGuids) {

        If ($Userguid.ToString().ToLower() -ne "all") {
            $URI = "https://graph.microsoft.com/beta/users/$Userguid"
            $UserObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            If (!$UserObject) {
                Throw "User: $Userguid specified in the Policy was not found in the directory. Create user, or update your policy."
            }  
            $UserUserPrincipalNames += ($UserObject.UserPrincipalName)
        }
    Else {
        $UserUserPrincipalNames = $null
        $UserUserPrincipalNames += "All"
    }
}
    Return $UserUserPrincipalNames
}