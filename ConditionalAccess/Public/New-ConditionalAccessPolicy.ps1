function New-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The New-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to create a new Conditional Access Policy, using a .JSON file as input. 
    
    .Description
    The command takes the content of the JSON file and converts it to an Powershell Object so that the data in the JSON can be correctly translated to input accepted by Graph. 
    It is possible to add a file containing the Policy directly through the -PoliyFile parameter. The script will automatically convert the file to a JSON object. 

    In order to allow for more flexibility rolling out the exact same JSONS to dIfferent Tenants while maintaining the readability of the JSON policy files:
    - The "DisplayNames" of "Groups", Roles and "Applications" are automatically translated to their respective ObjectIDs (GUIDs) as they are found in the targeted Tenant in the background. 
    - The "UserPrincipalNames" of "Users" are automatically translated to their respective ObjectIDs (GUIDs) as they are found the targeted Tenant in the background.

    The -CreateMissingGroups Paramter can be added to automatically create "Groups" based on the displayNames found in the JSON If no correlating "Groups" are found in the target tenant.  

    Prerequisites
    - Valid Access Token with the minimum following API permissions:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.ReadWrite.ConditionalAccess
        RoleManagement.Read.Directory
        The Command automatically converts existing DisplayNames from the JSON to their ObjectIDs (GUIDs) in the targeted Tenant. 

        -Optional permission for automatic group creation 
        Group.Create
    
    More info and source code;
    https://github.com/Fortigi/ConditionalAccess

    .Example 
    #Create a new Conditional Access Policy
    $PolicyJson = Get-content -path <YourFile.Json> -raw
    New-ConditionalAccessPolicy -PolicyJson $PolicyJson -AccessToken $AccessToken

    #Deploy a policy set and create any non existing groups 
    $PolicyFiles = get-childitem <your directory>
    foreach <PolicyFile in PolicyFiles>{
        New-ConditionalAccessPolicy -AccessToken $AccessToken -PolicyFile $PolicyFile -Force $True
    }
    #>

    [cmdletbinding()]
    Param
    (
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "PolicyJson")]
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = "PolicyFile")]
        
        [Parameter(Mandatory = $true, Position = 0)]
        $AccessToken,

        [Parameter(Mandatory = $true, ParameterSetName = "PolicyJson")]
        [ValidateNotNullOrEmpty()]
        $PolicyJson,

        [Parameter(Mandatory = $true, ParameterSetName = "PolicyFile")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        $PolicyFile,
        [Parameter(Mandatory = $False)]
        [System.Boolean]$CreateMissingGroups,  

        [Parameter(Mandatory = $False)]
        [System.Boolean]$TestOnly = $False
    )

    If ($PolicyFile) {
        $PolicyJson = Get-content -path $PolicyFile -raw 
    }

    if ($TestOnly -eq $True){
        if ($CreateMissingGroups -eq $true){
            Throw "Combination of CreateMissingGroup Parameter and TestOnly Parameter cannot both be true."
        }
        
    }

    #Convert JSON to Powershell
    $PolicyPS = $PolicyJson | convertFrom-Json
    
    
    
    #Get GUIDs for the DisplayNames of the Groups from the Powershell-representation of the JSON, from AzureAD through use of Microsoft Graph. 
    [array]$InclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.includeGroups) -AccessToken $AccessToken -CreateMissingGroups $CreateMissingGroups
    [array]$ExclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.excludeGroups) -AccessToken $AccessToken -CreateMissingGroups $CreateMissingGroups
    #Get GUIDs for the UserPrincipalNames of the Users from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionUsersGuids = ConvertFrom-UserUserPrinicpleNameToGUID -UserUserPrincipalNames ($PolicyPs.conditions.users.includeUsers) -AccessToken $AccessToken 
    [array]$ExclusionUsersGuids = ConvertFrom-UserUserPrinicpleNameToGUID -UserUserPrincipalNames ($PolicyPs.conditions.users.ExcludeUsers) -AccessToken $AccessToken 
    #Get GUIDs for the DisplayName of the Application from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionApplicationGuids = ConvertFrom-ApplicationDisplayNametoGUID -ApplicationDisplayNames ($PolicyPs.conditions.applications.includeApplications) -AccessToken $AccessToken 
    [array]$ExclusionApplicationGuids = ConvertFrom-ApplicationDisplayNametoGUID -ApplicationDisplayNames ($PolicyPs.conditions.applications.excludeApplications) -AccessToken $AccessToken 
    #Get GUIDs for the RoleDisplayName of the Roles from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionRoleGuids = ConvertFrom-RoleDisplayNametoGUID -RoleDisplayNames ($PolicyPs.conditions.users.includeRoles) -AccessToken $AccessToken 
    [array]$ExclusionRoleGuids = ConvertFrom-RoleDisplayNametoGUID -RoleDisplayNames ($PolicyPs.conditions.users.excludeRoles) -AccessToken $AccessToken 
   
    #Convert the Displaynames in the Powershell-object to the GUIDs.  
    If ($InclusionGroupsGuids) {
        $PolicyPs.conditions.users.includeGroups = $InclusionGroupsGuids
    }
    If ($ExclusionGroupsGuids) {
        $PolicyPs.conditions.users.excludeGroups = $ExclusionGroupsGuids
    }
    If ($InclusionUsersGuids) { 
        $PolicyPs.conditions.users.includeUsers = $InclusionUsersGuids
    }
    If ($ExclusionUsersGuids) { 
        $PolicyPs.conditions.users.ExcludeUsers = $ExclusionUsersGuids
    }
    If ($inclusionApplicationGuids) { 
        $PolicyPs.conditions.applications.includeApplications = $InclusionApplicationGuids
    }
    If ($ExclusionApplicationGuids) { 
        $PolicyPs.conditions.applications.excludeApplications = $ExclusionApplicationGuids
    }
    If ($InclusionRoleGuids) { 
        $PolicyPs.conditions.users.includeRoles = $InclusionRoleGuids
    } 
    If ($ExclusionRoleGuids) { 
        $PolicyPs.conditions.users.excludeRoles = $ExclusionRoleGuids 
    }
    
    #If ID and creation date, set to null
    If ($PolicyPs.id) {
        $policyPS.psobject.Properties.remove('id')
    }
    if ($PolicyPs.createdDateTime) {
        $PolicyPS.createdDateTime = $null
    }
    if ($PolicyPs.modifiedDateTime) {
        $PolicyPS.modifiedDateTime = $null
    }

    #Converts Powershell-Object with new Configuration back to Json
    $ConvertedPolicyJson = $PolicyPS | ConvertTo-Json -depth 3
    #Create new Policy using Graph
    If($TestOnly -eq $False){
    $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Post -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $AccessToken" } -Body $ConvertedPolicyJson -ContentType "application/json"
    $conditionalAccessPolicyResponse 
    }
    Else{Write-Warning -Message ("TestOnly was set, Policy: "+$PolicyPs.displayName+ " was not created. If no error was shown, Policy would have been succesfully created.")}
}


