function ConvertFrom-RoleDisplayNametoGUID {
      <#
    .SYNOPSIS
    The ConvertFrom-RoleDisplayNametoGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Roles to their GUIDs of the Roletemplates as they exist in the targeted Tenant. 
    
    .Description
        The command fills an object with the Role Template objects as found in the target directory. It then cycles through each Role displayName and attempts to match The displayName from parameter to the DisplayName 
        of the Role Template Object. If there is a match, the GUID is added for the conversion. If there is no match the command looks at directory roles to look for a match based on displayName. 
        If there is a match, the GUID is added for the conversion.     

     Prerequisites
    - Valid Access Token with the minimum following API permissions:
        RoleManagement.Read.Directory

    .Example 
    [array]$RoleDisplayNames = "Company Administrator"
    ConvertFrom-GroupDisplayNameToGUID -RoleDisplayNames $RoleDisplayNames -Force $true -AccessToken $AccessToken
    #> 
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$RoleDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    #Empty role GUID array
    [array]$RoleGuids = $null

    #Get RoleTemplate Objects from Graph
    $URI = "https://graph.microsoft.com/beta/directoryRoletemplates"
    $RoleTemplates = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
    [array]$Roles = $Roletemplates.value

    if ($RoleDisplayNames -eq "All"){
        [array]$RoleDisplayNames = $null
        foreach ($Role in $Roles){
            $RoleDisplayNames += $Role.displayName
    }
}

    #For each in Policy File stated Role (DisplayName), attempt to map ObjectIDs based on Matching DisplayNames.    
    foreach ($RoleDisplayName in $RoleDisplayNames) {

        #Find role in Default roles set.
        $Found = $Roles | Where-Object { $_.DisplayName -eq $RoleDisplayName }

        If ($Found) {
            $RoleGuids += ($Found.Id) 
        }
        Else {
            $URI = "https://graph.microsoft.com/beta/directoryRoles?" + '$filter' + "=displayName eq '$RoleDisplayName'"
            $RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$RoleObject.value) {
                throw "Role $RoleDisplayName is not found."
            }
            $RoleGuids += ($RoleObject.value.id) 
        } 
    
    }
    Return $RoleGuids
}
