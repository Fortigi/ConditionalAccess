function ConvertFrom-LocationDisplayNameToGUID {
    <#
.SYNOPSIS
The ConvertFrom-LocationDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Locations to their GUIDs as they exist in the targeted Tenant. 

.Description
    
.Description
  The command takes the array of DisplayNames of Locations from the input in the parameter and checks their existence in the targeted AzureAD tenant. If the LocationDisplayName Exists the GUID is returned
  And added to the LocationGUIDs array. 

Prerequisites
- Valid Access Token with the minimum following API permissions:
  Locations.Read.All


.Example 
[array]$LocationDisplayNames = "william@fortigi.nl"
ConvertFrom-LocationDisplayNameGUID -LocationDisplayNames $LocationDisplayNames -AccessToken $AccessToken
#>

Param
(
  [Parameter(Mandatory = $false)]
  [array]$LocationDisplayNames,
  [Parameter(Mandatory = $true)]
  $AccessToken 
)

[array]$LocationGuids = $null

Foreach ($LocationDisplayName in $LocationDisplayNames) {

  If ($LocationDisplayName.ToString().ToLower() -ne "all") {
      $URI = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations?" + '$filter' + "=DisplayName eq '$LocationDisplayName'"
      $LocationObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
      If (!$LocationObject.value) {
          Throw "Location: $LocationDisplayName specified in the Policy was not found in the directory. Create Location, or update your policy."
      }
      if ($locationobject.value.count -gt 1){
          Throw "More than one Object was found for Location DisplayName: $LocationDisplayName"
      }  
      $LocationGuids += ($LocationObject.value.id)
  }
Else {
  $LocationGuids = $null
  $LocationGuids += "All"
}
}
Return $LocationGuids
}

