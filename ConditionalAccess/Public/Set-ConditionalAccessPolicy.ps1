function Set-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The Set-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to update a new Conditional Access Policy, using a .JSON file as input. 
    
    .Description
    The command takes the content of the JSON file and converts it to an Powershell Object so that the data in the JSON can be correctly translated to input accepted by Graph. 

    In order to allow for more flexibility rolling out the exact same JSONS to different Tenants while maintaining the readability of the JSON policy files:
    - The "DisplayNames" of "Groups" and "Applications" are automatically translated to their respective ObjectIDs (GUIDs) as they are found in the targeted Tenant in the background. 
    - The "UserPrincipalNames" of "Users" are automatically translated to their respective ObjectIDs (GUIDs) as they are found the targeted Tenant in the background.

    The -Force Paramter can be added to automatically create "Groups" based on the displayNames found in the JSON if no correlating "Groups" are found in the target tenant.  

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.ReadWrite.ConditionalAccess
        The Command automatically converts existing DisplayNames from the JSON to their ObjectIDs (GUIDs) in the targeted Tenant. 

        -Optional permission for automatic group creation 
        Group.Create
    #>

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $PolicyJson,
        [Parameter(Mandatory = $true)]
        $accessToken,
        [Parameter(Mandatory = $false)]
        $Id,
        [Parameter(Mandatory = $False)]
        [System.Boolean]$Force  
    )
    
    #Convert JSON to Powershell
    $PolicyPS = $PolicyJson | convertFrom-Json

    #Get GUIDs for the DisplayNames of the Groups from the Powershell-representation of the JSON, from AzureAD through use of Microsoft Graph. 
    [array]$InclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.includeGroups) -accessToken $accessToken -Force $Force
    [array]$ExclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.excludeGroups) -accessToken $accessToken -Force $Force
    #Get GUIDs for the UserPrincipalNames of the Users from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionUsersGuids = ConvertFrom-UserUserPrinicpleNameToGUID -UserUserPrincipalNames ($PolicyPs.conditions.users.includeUsers) -accessToken $accessToken 
    [array]$ExclusionUsersGuids = ConvertFrom-UserUserPrinicpleNameToGUID -UserUserPrincipalNames ($PolicyPs.conditions.users.ExcludeUsers) -accessToken $accessToken 
    #Get GUIDs for the DisplayName of the Application from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionApplicationGuids = Get-UserGuidForApplicationDisplayName -GroupDisplayNames ($PolicyPs.conditions.applications.includeApplications) -accessToken $accessToken 
    [array]$ExclusionApplicationGuids = Get-UserGuidForApplicationDisplayName -GroupDisplayNames ($PolicyPs.conditions.applications.excludeApplications) -accessToken $accessToken 

    #Convert the Displaynames in the Powershell-object to the GUIDs.  
    $PolicyPs.conditions.users.includeGroups = $InclusionGroupsGuids
    $PolicyPs.conditions.users.excludeGroups = $ExclusionGroupsGuids
    $PolicyPs.conditions.users.includeUsers = $InclusionUsersGuids
    $PolicyPs.conditions.users.ExcludeUsers = $ExclusionUsersGuids
    $PolicyPs.conditions.applications.includeApplications = $InclusionApplicationGuids
    $PolicyPs.conditions.applications.excludeApplications = $ExclusionApplicationGuids
    
    #Converts includeGroups and excludeGroups configuration in JSON from displayName to GUID.
    $ConvertedPolicyJson = $PolicyPS | ConvertTo-Json

    $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Patch -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $accessToken" } -Body $ConvertedPolicyJson -ContentType "application/json"
    $conditionalAccessPolicyResponse     
}