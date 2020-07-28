function ConvertFrom-RoleGUIDtoDisplayName {
      <#
    .SYNOPSIS
    The ConvertFrom-RoleGUIDtoDisplayName command uses a Token from the "Get-AccessToken" command to convert the [array]GUIDs of Roles to their DisplayNames of the Roletemplates as they exist in the targeted Tenant. 
    
    .Description
        The command fills an object with the Role Template objects as found in the target directory. It then cycles through each Role displayName and attempts to match The displayName from parameter to the DisplayName 
        of the Role Template Object. If there is a match, the GUID is added for the conversion. If there is no match the command looks at directory roles to look for a match based on displayName. 
        If there is a match, the GUID is added for the conversion.     

     Prerequisites
    - Valid Access Token with the minimum following API permissions:
        RoleManagement.Read.Directory

    .Example 
    [array]$RoleGuids = "xxxx-xxxx-xxxxx-xxxxx"
    ConvertFrom-RoleGUIDtoDisplayName -RoleGuid $RoleGuids -Force $true -AccessToken $AccessToken
    #> 
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$RoleGuids,
        [Parameter(Mandatory = $true)]
        $AccessToken 
    )
    #Empty role DisplayName array
    [array]$RoleDisplayNames = $null

    #Get RoleTemplate Objects from Graph
    $URI = "https://graph.microsoft.com/beta/directoryRoletemplates"
    $RoleTemplates = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
    [array]$Roles = $RoleTemplates.value

    #For each in Policy File stated Role (DisplayName), attempt to map ObjectIDs based on Matching DisplayNames.    
    Foreach ($RoleGuid in $RoleGuids) {

        #Find role in Default roles set.
        $Found = $Roles | Where-Object { $_.id -eq $RoleGuid }

        If ($Found) {
            $RoleDisplayNames += ($Found.displayName) 
        }
        #if Roletemplate cant be found, check existing roles. 
        Else {
            $URI = "https://graph.microsoft.com/beta/directoryRoles?" + '$filter' + "=displayName eq '$RoleDisplayName'"
            $RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
            If (!$RoleObject.value) {
                Throw "Role $RoleGuid is not found as RoleTemplate or DirectoryRole."
            }
            $RoleDisplayNames += ($RoleObject.value.displayName) 
        } 
    
    }
    Return $RoleDisplayNames
}
