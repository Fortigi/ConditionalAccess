function ConvertFrom-AgreementGuidToDisplayName {
    <#
    .SYNOPSIS
    The ConvertFrom-AgreementDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Agreements to their respective GUIDs as they exist in the targeted AzureAD tenant. 
    
    .Description
        The command takes the array of displaynames of applications from the JSON file and checks their existence in the targeted AzureAD tenant. 

     Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Agreement.Read.All

        -Optional permission for automatic Agreement creation through use of the -CreateMissingAgreements parameter
        Agreement.Create OR Agreement.Readwrite.All

    .Example 
    [array]$AgreementDisplayNames = "InclusionAgreement1"
    ConvertFrom-AgreementDisplayNameToGUID -AgreementDisplayNames $AgreementDisplayNames -Force $true -AccessToken $AccessToken
    #>
    Param
    (
        [Parameter(Mandatory = $false)]
        [array]$AgreementGuids,
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [parameter(mandatory = $false)]
        $PathConvertFile
    )

    [array]$AgreementDisplayNames = $null  
    
    Foreach ($AgreementGuid in $AgreementGuids) {
        $ConvertFile = Get-Content -Path $PathConvertFile -Raw | ConvertFrom-Json
        If (!$ConvertFile) {
            Throw "One or more policies contain TermsofUse objects. Please give the correct path for the Convert.Json file in order to convert TermsOfUse GUIDs to their corresponding DisplayNames"
        }
        $Tenant = $null
        $Tenant = $ConvertFile | where-object { $_.TermsOfUse.tenant.TermsOfUseObjectID -eq $AgreementGuid } 
        If ($Tenant) {
            Write-Host "Converting Guid: $agreementGuid to corresponding DiplayName."
            $AgreementDisplayNames += ($convertfile.Termsofuse.Displayname)
        }
        if (!$Tenant) {
            Throw "Inconsistency between GUIDs in Graph: $AgreementGuid and GUIDs in Convert.Json. Please update the file to match"
        }
    }
    Return $AgreementDisplayNames
}




#Below in preparation for when Agreements are supported by the Graph API via application permissions    
#    Foreach ($AgreementGuid In $AgreementGuids) {
#        $URI = "https://graph.microsoft.com/beta/Agreements/$AgreementGuid"
#        $AgreementObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
#        if ($AgreementObject.count -gt 1) {
#            Write-Warning "More than one Object was found for Agreement DisplayName: $LocationDisplayName"
#          }  
#        #Add ID to AgreementGuids
#        $DisplayName = ($AgreementObject.displayName)
#        [array]$AgreementDisplayNames += $DisplayName
#    }
#    Return [array]$AgreementDisplayNames
#}

