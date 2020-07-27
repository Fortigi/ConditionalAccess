function ConvertFrom-GroupGuidToDisplayName {
     <#
    .SYNOPSIS
    The ConvertFrom-GroupDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Groups to their respective GUIDs as they exist in the targeted AzureAD tenant. 
    
    .Description
        The command takes the array of displaynames of applications from the JSON file and checks their existence in the targeted AzureAD tenant. 

     Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Group.Read.All

        -Optional permission for automatic group creation through use of the -CreateMissingGroups parameter
        Group.Create OR Group.Readwrite.All

    .Example 
    [array]$GroupDisplayNames = "InclusionGroup1"
    ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames $GroupDisplayNames -Force $true -AccessToken $AccessToken
    #>
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$GroupGuids,
        [Parameter(Mandatory = $true)]
        $AccessToken
    )

    [array]$GroupDisplayNames = $null  

    Foreach ($GroupGuid In $GroupGuids) {
        $URI = "https://graph.microsoft.com/beta/groups/$GroupGuid"
        $GroupObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
        #Add ID to GroupGuids
        $Guid = ($GroupObject.displayName)
        [array]$GroupDisplayNames += $Guid
    }
    Return [array]$GroupDisplayNames
}