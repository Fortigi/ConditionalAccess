function ConvertFrom-LocationGUIDToDisplayName {
  <#
.SYNOPSIS
The ConvertFrom-LocationGUIDToLocationDisplayName command uses a Token from the "Get-AccessToken" command to convert the [array]LocationGuids of Locations to their DisplayNames as they exist in the targeted Tenant. 

.Description
    
.Description
  The command takes the array of DisplayNames of Locations from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the LocationDisplayName Exists the GUID is returned
  And added to the LocationGUIDs array. 

Prerequisites
- Valid Access Token with the minimum following API permissions:
  Locations.Read.All


.Example 
[array]$LocationGuids = "william@fortigi.nl"
ConvertFrom-LocationGUIDToDisplayName -LocationGuids $LocationGuids -AccessToken $AccessToken
#>

  Param
  (
    [Parameter(Mandatory = $false)]
    [array]$LocationGuids,
    [Parameter(Mandatory = $true)]
    $AccessToken 
  )

  [array]$LocationDisplayNames = $null

  Foreach ($Locationguid in $LocationGuids) {

    If ($Locationguid.ToString().ToLower() -ne "all") {
      $URI = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/$Locationguid"
      $LocationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
      If (!$LocationObject) {
        Throw "Location: $Locationguid specified in the Policy was not found in the directory. Create Location, or update your policy."
      }  
      $LocationDisplayNames += ($LocationObject.DisplayName)
    }
    Else {
      $LocationDisplayNames = $null
      $LocationDisplayNames += "All"
    }
  }
  Return $LocationDisplayNames
}