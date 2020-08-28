function ConvertFrom-UserDisplayNameToGUID {
          <#
    .SYNOPSIS
    The ConvertFrom-UserDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Users to their GUIDs as they exist in the targeted Tenant. 
    
    .Description
          
    .Description
        The command takes the array of DisplayNames of Users from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the UserDisplayName Exists the GUID is returned
        And added to the UserGUIDs array. 

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Users.Read.All


    .Example 
    [array]$UserDisplayNames = "william@fortigi.nl"
    ConvertFrom-UserDisplayNameGUID -UserDisplayNames $UserDisplayNames -AccessToken $AccessToken
    #>
    
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$UserDisplayNames,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )
    
    [array]$UserGuids = $null

    Foreach ($UserDisplayName in $UserDisplayNames) {

        If ($UserDisplayName.ToString().ToLower() -ne "all") {
            $URI = "https://graph.microsoft.com/beta/users?" + '$filter' + "=DisplayName eq '$UserDisplayName'"
            $UserObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            If (!$UserObject.value) {
                Throw "User: $UserDisplayName specified in the Policy was not found in the directory. Create user, or update your policy."
            }  
            if ($UserObject.count -gt 1){
                Throw "More than one Object was found for $UserDisplayName"
            }
            $UserGuids += ($UserObject.value.id)
        }
    Else {
        $UserGuids = $null
        $UserGuids += "All"
    }
}
    Return $UserGuids
}

