function Set-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The Set-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to update a new Conditional Access Policy, using a .JSON file as input. 
    
    .Description
    The command takes the content of the JSON file and converts it to an Powershell Object so that the data in the JSON can be correctly translated to input accepted by Graph. 

    In order to allow for more flexibility rolling out the exact same JSONS to different Tenants while maintaining the readability of the JSON policy files:
    - The "DisplayNames" of "Groups", Users and "Applications" in the JSON are automatically translated to their respective ObjectIDs (GUIDs) as they are found in the targeted Tenant in the background. 

    The -CreateMissingGroups Paramter can be set to $true to automatically create "Groups" based on the displayNames found in the JSON if no correlating "Groups" are found in the target tenant.  

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

        [Parameter(Mandatory = $true)]
        $Id,
        
        [Parameter(Mandatory = $False)]
        [System.Boolean]$TestOnly = $False,

        [Parameter(Mandatory = $False)]
        $PathConvertFile,
        [Parameter(Mandatory = $False)]
        $TargetTenantName,
        [Parameter(Mandatory = $False)]
        [System.Boolean]$CreateMissingGroups  
    )
    
    If ($PolicyFile) {
        $PolicyJson = Get-content -path $PolicyFile -raw 
    }
    
    If ($PathConvertFile) {
        If (!($TargetTenantName)) {
            Throw "When specifying a ConvertFile you also need to specify the TargetTenantName variable."
        }
    }
    
    #Convert JSON to Powershell
    $PolicyPS = $PolicyJson | convertFrom-Json

    #Get GUIDs for the DisplayNames of the Groups from the Powershell-representation of the JSON, from AzureAD through use of Microsoft Graph. 
    [array]$InclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.includeGroups) -AccessToken $AccessToken -CreateMissingGroups $CreateMissingGroups
    [array]$ExclusionGroupsGuids = ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames ($PolicyPs.conditions.users.excludeGroups) -AccessToken $AccessToken -CreateMissingGroups $CreateMissingGroups
    #Get GUIDs for the DisplayName of the Users from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionUsersGuids = ConvertFrom-UserDisplayNameToGUID -UserDisplayNames ($PolicyPs.conditions.users.includeUsers) -AccessToken $AccessToken 
    [array]$ExclusionUsersGuids = ConvertFrom-UserDisplayNameToGUID -UserDisplayNames ($PolicyPs.conditions.users.ExcludeUsers) -AccessToken $AccessToken 
    #Get GUIDs for the DisplayName of the Application from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionApplicationGuids = ConvertFrom-ApplicationDisplayNametoGUID -ApplicationDisplayNames ($PolicyPs.conditions.applications.includeApplications) -AccessToken $AccessToken 
    [array]$ExclusionApplicationGuids = ConvertFrom-ApplicationDisplayNametoGUID -ApplicationDisplayNames ($PolicyPs.conditions.applications.excludeApplications) -AccessToken $AccessToken 
    #Get GUIDs for the DisplayName of the Roles from the Powershell representation of the JSON, from AzureAD through use of Microsoft Graph.
    [array]$InclusionRoleGuids = ConvertFrom-RoleDisplayNametoGUID -RoleDisplayNames ($PolicyPs.conditions.users.includeRoles) -AccessToken $AccessToken 
    [array]$ExclusionRoleGuids = ConvertFrom-RoleDisplayNametoGUID -RoleDisplayNames ($PolicyPs.conditions.users.excludeRoles) -AccessToken $AccessToken 
    #Get GUIDs for the DisplayName of the Locations from the Powershell representation of the JSON, from AzureAD through the use of Microsoft Graph. 
    [array]$InclusionLocationGuids = ConvertFrom-LocationDisplayNameToGUID -LocationDisplayNames ($PolicyPs.conditions.locations.includeLocations) -AccessToken $AccessToken 
    [array]$ExclusionLocationGuids = ConvertFrom-LocationDisplayNameToGUID -LocationDisplayNames ($PolicyPs.conditions.locations.ExcludeLocations) -AccessToken $AccessToken 
    #Get GUIds for the DisplayName of TermsofUse (Agreement-object) in the targeted tenant. The Convert.Json file to function since Graph does not support this functionality yet. 
    [array]$AgreementGuids = ConvertFrom-AgreementDisplayNameToGUID -AgreementDisplayNames ($PolicyPS.grantControls.termsOfUse) -AccessToken $AccessToken -PathConvertFile $PathConvertFile -TargetTenantName $TargetTenantName

   
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
    If ($InclusionLocationGuids) { 
        $PolicyPs.conditions.locations.includeLocations = $InclusionLocationGuids
    } 
    If ($ExclusionLocationGuids) { 
        $PolicyPs.conditions.locations.excludeLocations = $ExclusionLocationGuids 
    }
    If ($AgreementGuids) { 
        $PolicyPS.grantControls.termsOfUse = $AgreementGuids 
    }
    
    #If ID and creation date, set to null
    If ($PolicyPs.id) {
        $policyPS.id = $Id
    }
    if ($PolicyPs.createdDateTime) {
        $PolicyPS.createdDateTime = $null
    }
    if ($PolicyPs.modifiedDateTime) {
        $PolicyPS.modifiedDateTime = $null
    }

    #Converts Powershell-Object with new Configuration back to Json
    $ConvertedPolicyJson = $PolicyPS | ConvertTo-Json -depth 3

    If ($TestOnly -eq $False) {
        $ConditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
        $ConditionalAccessPolicyResponse = Invoke-RestMethod -Method Patch -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $AccessToken" } -Body $ConvertedPolicyJson -ContentType "application/json"
        $ConditionalAccessPolicyResponse     
    }
    Else { 
        Write-Host ("TestOnly was set, Policy: " + $PolicyPs.displayName + " was not updated. If no error was shown, Policy would have been succesfully updated.") -ForegroundColor Green
    }
}