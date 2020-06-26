function ConvertFrom-GroupDisplayNameToGUID {
     <#
    .SYNOPSIS
    The ConvertFrom-GroupDisplayNameToGUID command uses a Token from the "Get-AccessToken" command to convert the [array]DisplayNames of Groups to their respective GUIDs as they exist in the targeted AzureAD tenant. 
    
    .Description
        The command takes the array of displaynames of applications from the JSON file and checks their existence in the targeted AzureAD tenant. 

     Prerequisites
    - Valid Access Token with the minimum following API permissions:
        Group.Read.All

        -Optional permission for automatic group creation through use of the -force parameter
        Group.Create OR Group.Readwrite.All

    .Example 
    [array]$GroupDisplayNames = "InclusionGroup1"
    ConvertFrom-GroupDisplayNameToGUID -GroupDisplayNames $GroupDisplayNames -Force $true -AccessToken $AccessToken
    #>
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$GroupDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken,
        [Parameter(Mandatory = $False)]
        [System.Boolean]$Force  
    )

    [array]$GroupGuids = $null
    
    foreach ($GroupDisplayName in $GroupDisplayNames) {
        $URI = "https://graph.microsoft.com/beta/groups?" + '$filter' + "=displayName eq '$GroupDisplayName'"
        $GroupObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
        If (!$GroupObject.value) {
            if ($Force -ne $true ) { 
                throw "The group specified in the policy JSON could not be found in AzureAD. Group Displayname: $GroupDisplayName. Use -Force paramater to auto create groups."
            }  
            if ($Force -eq $true ) {
                write-host "Creating Azure AD Group: $GroupDisplayName" -ForegroundColor Yellow
                
                #Define group JSON template
                $GroupFile = '{
                "description": "GrpDescription",
                "displayName": "GrpDisplayName",
                "mailEnabled": false,
                "securityEnabled": true
                }'

                #Create a mailnickname
                #$MailNickName = $GroupDisplayName.Replace(" ","")
                #If ($MailNickName.Length -gt 19) {
                #    $MailNickName = $MailNickName.Substring(0,19)
                #}

                #Convert GroupJSON to Powershell
                $GroupPS = $GroupFile | ConvertFrom-Json
                #Fill PS object with correct Displayname and Description
                $GroupPS.displayName = $GroupDisplayName
                $GroupPS.description = $GroupDisplayName
                #$GroupPS.mailNickname = $MailNickName
                $GroupPS.mailEnabled = $False
                $GroupPS.securityEnabled = $true
                #Convert to JSON
                $NewGroupJson = $GroupPS | ConvertTo-Json
                #Create the group using the Json as input
                $URI = "https://graph.microsoft.com/beta/groups?" + '$filter' + "=displayName eq '$GroupDisplayName'"
                Invoke-RestMethod -Method Post -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } -Body $NewGroupJson -ContentType "application/json"
                #Delay after creation
                Start-Sleep -s 5
                #Fill GroupObject with the newly created group
                $URI = "https://graph.microsoft.com/beta/groups?" + '$filter' + "=displayName eq '$GroupDisplayName'"
                $GroupObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" }

                if ($GroupObject) {
                    write-host "Success" -ForegroundColor Green
                }
                else {
                    Throw "Error creating group."
                }
            }
        }
        #Add ID to GroupGuids
        $GroupGuids += ($GroupObject.value.id)
    }
    Return $GroupGuids
}