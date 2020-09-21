Function Deploy-ConditionalAccessPolicies {
    Param (
        [Parameter(Mandatory = $True)]
        [System.String]$ClientId,
        [Parameter(Mandatory = $True)]
        [System.String]$ClientSecret,       
        [Parameter(Mandatory = $True)]
        [System.String]$TenantId,

        [Parameter(Mandatory = $True)]
        [System.String]$PolicyFileLocation,    

        [Parameter(Mandatory = $True)]
        [System.String]$PathConvertFile,
        [Parameter(Mandatory = $True)]
        [System.String]$TargetTenantName,
        
        [Parameter(Mandatory = $true)]
        [System.Boolean]$TestOnly,
        
        [Parameter(Mandatory = $true)]
        [System.Boolean]$Overwrite,
        
        [Parameter(Mandatory = $true)]
        [System.Boolean]$RemoveExisting
    )

    #Get a token
    $AccessToken = Get-AccessToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret

    #Get Policies for this deployment
    $Policies = Get-ChildItem -Path $PolicyFileLocation
    Write-Host ("Found: "+ $Policies.Count +" to import.")

    #Get existing policies from tenant
    $ExistingPolicies = Get-ConditionalAccessPolicy -AccessToken $AccessToken -ConvertGUIDs $false
    Write-Host ("Found: "+ $ExistingPolicies.Count +" existing policies.")

    Foreach ($Policy in $Policies) {
        
        #Get policy displayname
        $PolicyJson = Get-Content -Raw -Path $Policy.FullName | ConvertFrom-Json
        $PolicyDisplayName = $PolicyJson.displayName

        #Determin policy already exists in tenant
        $Exists = $False
        $Exists = $ExistingPolicies | Where-Object { $_.displayName -eq $PolicyDisplayName }

        If ($Exists) {
            if ($TestOnly) {
                Set-ConditionalAccessPolicy -Id $Exists.id -AccessToken $AccessToken -PolicyFile $Policy.FullName -PathConvertFile $PathConvertFile -TargetTenantName $TargetTenantName -TestOnly $True
            }
            Else {
                If ($Overwrite) {
                    Write-Host "Updating $PolicyDisplayName." -ForegroundColor Green
                    Set-ConditionalAccessPolicy -Id $Exists.id -AccessToken $AccessToken -PolicyFile $Policy.FullName -PathConvertFile $PathConvertFile -TargetTenantName $TargetTenantName
                }
                else {
                    Write-Warning -Message "Policy $PolicyDisplayName was ignored because the Overwrite parameter was set to false"
                }
            }
        }
        Else {
            
            if ($TestOnly) {
                New-ConditionalAccessPolicy -AccessToken $AccessToken -PolicyFile $Policy.FullName -PathConvertFile $PathConvertFile -TargetTenantName $TargetTenantName -TestOnly $True
            }
            else {
                Write-Host "Creating $PolicyDisplayName." -ForegroundColor Green
                New-ConditionalAccessPolicy -AccessToken $AccessToken -PolicyFile $Policy.FullName -PathConvertFile $PathConvertFile -TargetTenantName $TargetTenantName
            }
        }
    }

    #Detect if policy is new or existing
    Foreach ($ExistingPolicy in $ExistingPolicies) {
    
        $Found = $false

        Foreach ($Policy in $Policies) {
            $PolicyJson = Get-Content -Raw -Path $Policy.FullName | ConvertFrom-Json
            $PolicyDisplayName = $PolicyJson.displayName

            if ($ExistingPolicy.displayName -eq $PolicyDisplayName) {
                $Found = $True
            }
        }

        If ($Found -eq $false) {
            
            $DisplayName = $ExistingPolicy.displayname

            if ($RemoveExisting) {
                if ($TestOnly) {
                    Write-Warning "Test Only was set. If run without testonly policy: $DisplayName will be removed because it is not part of the deployment set."
                }
                else {
                    Write-Warning "Removing $DisplayName."
                    Remove-ConditionalAccessPolicy -Id $ExistingPolicy.id -AccessToken $AccessToken
                }
            }
            Else {
                Write-Warning "Current setup contains $DisplayName that is not part of this deployment. Use RemoveExisting varabile to remove any policies that don't exist in the deployment setup."
            }
        }
    }


}
