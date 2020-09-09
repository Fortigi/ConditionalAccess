function Get-ConditionalAccessPolicy {
    <#
    .SYNOPSIS
    The Get-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to get some or all of the Conditional Access policies in the targeted AzureAD tenant. 
    
    .Description
    The Get-ConditionalAccessPolicy command uses a Token from the "Get-AccessToken" command to get some or all of the Conditional Access policies in the targeted AzureAD tenant. Depending on the 
    -ConvertGUIDs parameter, it will automatically convert the non-human readable GUIDs in Graph to human readable Displaynames.

    Prerequisites
    - App registered in the target Azure Active Directory
    - Valid client secret of the App
    - The App needs to have at least the followwing Admin Consented API permissions to be used for Conditional Access policies*:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.Read.ConditionalAccess
    
    More info and source code;
    https://github.com/Fortigi/ConditionalAccess

    .example 
    #Example to get All policies
    Get-ConditionalAccessPolicy -AccessToken $AccessToken

    #Example to get a specIfic policy based on DisplayName
    $ConditionalAccessPolicyDisplayName = "CA-01- All Apps - All Admins - Require MFA"
    Get-ConditionalAccessPolicy -AccessToken $AccessToken -DisplayName $ConditionalAccessPolicyDisplayName
    #>
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [Parameter(Mandatory = $false)]
        $Id = $false,
        [Parameter(Mandatory = $false)]
        $DisplayName = $false,
        [Parameter(Mandatory = $false)]
        $ConvertGUIDs = $True,  
        [Parameter(Mandatory = $false)]
        $PathConvertFile 
    )

    If ($Id) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/{$Id}"
    }
    ElseIf ($DisplayName) {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=endswith(displayName, '$DisplayName')"
    }
    Else {
        $conditionalAccessURI = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies"
    }
    $conditionalAccessPolicyResponse = Invoke-RestMethod -Method Get -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $AccessToken" }

    [Array]$Policies = $conditionalAccessPolicyResponse.value    

    If ($ConvertGUIDs -eq $True) {

        #Guids from GUID to DisplayName
        Foreach ($Policy in $Policies) {
            [Array]$InclusionApplicationDisplayNames = ConvertFrom-ApplicationGUIDToDisplayName -ApplicationGuids ($Policy.conditions.applications.includeApplications) -AccessToken $AccessToken 
            [Array]$ExclusionApplicationDisplayNames = ConvertFrom-ApplicationGUIDToDisplayName -ApplicationGuids ($Policy.conditions.applications.excludeApplications) -AccessToken $AccessToken 
            [array]$InclusionUsersDisplayNames = ConvertFrom-UserGUIDToDisplayName -UserGUIDs ($Policy.conditions.users.includeUsers) -AccessToken $AccessToken 
            [array]$ExclusionUsersDisplayNames = ConvertFrom-UserGUIDToDisplayName -UserGUIDs ($Policy.conditions.users.ExcludeUsers) -AccessToken $AccessToken 
            [array]$InclusionGroupsDisplayNames = ConvertFrom-GroupGUIDToDisplayName -GroupGuids ($Policy.conditions.users.includeGroups) -AccessToken $AccessToken
            [array]$ExclusionGroupsDisplayNames = ConvertFrom-GroupGUIDToDisplayName -GroupGuids ($Policy.conditions.users.excludeGroups) -AccessToken $AccessToken
            [array]$InclusionRoleDisplayNames = ConvertFrom-RoleGUIDtoDisplayName -RoleGuids ($Policy.conditions.users.includeRoles) -AccessToken $AccessToken 
            [array]$ExclusionRoleDisplayNames = ConvertFrom-RoleGUIDtoDisplayName -RoleGuids ($Policy.conditions.users.excludeRoles) -AccessToken $AccessToken 
            [array]$InclusionLocationDisplayNames = ConvertFrom-LocationGUIDToDisplayName -LocationGuids ($Policy.conditions.locations.includeLocations) -AccessToken $AccessToken 
            [array]$ExclusionLocationDisplayNames = ConvertFrom-LocationGUIDtoDisplayName -LocationGuids ($Policy.conditions.locations.excludeLocations) -AccessToken $AccessToken 
            [array]$AgreementDisplayNames = ConvertFrom-AgreementGUIDToDisplayName -AgreementGuids ($Policy.grantControls.termsOfUse) -AccessToken $AccessToken -PathConvertFile $PathConvertFile 


            If ($InclusionApplicationDisplayNames) { 
                $Policy.conditions.applications.includeApplications = $InclusionApplicationDisplayNames
            }
            If ($ExclusionApplicationDisplayNames) { 
                $Policy.conditions.applications.excludeApplications = $ExclusionApplicationDisplayNames
            }
            If ($InclusionUsersDisplayNames) { 
                $Policy.conditions.users.includeUsers = $InclusionUsersDisplayNames
            }
            If ($ExclusionUsersDisplayNames) { 
                $Policy.conditions.users.ExcludeUsers = $ExclusionUsersDisplayNames
            }
            If ($InclusionGroupsDisplayNames) {
                $Policy.conditions.users.includeGroups = $InclusionGroupsDisplayNames
            }
            If ($ExclusionGroupsDisplayNames) {
                $Policy.conditions.users.excludeGroups = $ExclusionGroupsDisplayNames
            }
            If ($InclusionRoleDisplayNames) { 
                $Policy.conditions.users.includeRoles = $InclusionRoleDisplayNames
            } 
            If ($ExclusionRoleDisplayNames) { 
                $Policy.conditions.users.excludeRoles = $ExclusionRoleDisplayNames 
            }
            If ($InclusionLocationDisplayNames) { 
                $Policy.conditions.locations.includeLocations = $InclusionLocationDisplayNames 
            }
            If ($ExclusionLocationDisplayNames) { 
                $Policy.conditions.locations.excludeLocations = $ExclusionLocationDisplayNames 
            }
            If ($AgreementDisplayNames) { 
                $Policy.grantControls.termsOfUse = $AgreementDisplayNames 
            }

        }

        #Role GUIDs to DisplayName


    }
   
    return $Policies
   


}

