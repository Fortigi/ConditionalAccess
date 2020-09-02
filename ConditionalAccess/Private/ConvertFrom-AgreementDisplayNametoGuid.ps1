function ConvertFrom-AgreementDisplayNameToGUID {
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
        [array]$AgreementDisplayNames,
        [Parameter(Mandatory = $true)]
        $AccessToken,
        [parameter(mandatory = $false)]
        $PathConvertFile,
        [parameter(mandatory = $false)]
        $TargetTenant
    )

    [array]$AgreementGuids = $null  

    if ($AgreementDisplayNames) {
        $ConvertFile = Get-Content -Path $PathConvertFile -Raw | ConvertFrom-Json
    }
    Foreach ($AgreementDisplayname in $AgreementDisplaynames) {
        If (!$ConvertFile) {
            Throw "Please give the correct path for the Convert.Json file in order to convert TermsOfUse DisplayName to their corresponding GUIDs"
        }
        $Guid = $null
        $Guid = $ConvertFile.termsofuse.tenant | where-object { $_.tenantname -eq $TargetTenant } 
        If ($guid) {
            $AgreementGuids += $guid.TermsOfUseObjectID
        }
        if (!$Guid) {
            Throw "Mismatch between TargetTenant input and TenantName in JsonFile"
        }
    }
    Return $AgreementGuids
}




#Below in preparation for when Agreements are supported by the Graph API via application permissions    
#    Foreach ($AgreementDisplayname In $AgreementDisplaynames) {
#        $URI = "https://graph.microsoft.com/beta/Agreements/$AgreementDisplayname"
#        $AgreementObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $AccessToken" } 
#        if ($AgreementObject.count -gt 1) {
#            Write-Warning "More than one Object was found for Agreement DisplayName: $LocationDisplayName"
#          }  
#        #Add ID to AgreementDisplaynames
#        $DisplayName = ($AgreementObject.displayName)
#        [array]$AgreementDisplayNames += $DisplayName
#    }
#    Return [array]$AgreementDisplayNames
#}

