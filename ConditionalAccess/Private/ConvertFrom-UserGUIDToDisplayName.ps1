function ConvertFrom-UserGUIDToDisplayName {
          <#
    .SYNOPSIS
    The ConvertFrom-UserGUIDToUserDisplayName command uses a Token from the "Get-AccessToken" command to convert the [array]UserGuids of Users to their DisplayNames as they exist in the targeted Tenant. 
    
    .Description
          
    .Description
        The command takes the array of DisplayNames of Users from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the UserDisplayName Exists the GUID is returned
        And added to the UserGUIDs array. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Users.Read.All


    .Example 
    [array]$UserGuids = "william@fortigi.nl"
    ConvertFrom-UserGUIDToUserDisplayName -UserGuids $UserGuids -AccessToken $AccessToken
    #>
    
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$UserGuids,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )
    
    [array]$UserDisplayNames = $null

    Foreach ($Userguid in $UserGuids) {

        If ($Userguid -match '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$' ) {
            $URI = "https://graph.microsoft.com/beta/users/$Userguid"
            $UserObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            If (!$UserObject) {
                Throw "User: $Userguid specified in the Policy was not found in the directory. Create user, or update your policy."
            }  
            $UserDisplayNames += ($UserObject.DisplayName)
        }
    Else {
        $UserDisplayNames = $null
        $UserDisplayNames += $Userguid.ToString()
    }

}
    Return $UserDisplayNames
}