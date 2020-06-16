function ConvertFrom-GroupDisplayNameToGUID {
    param
    (
        [Parameter(Mandatory = $true)]
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
                throw "Group-object could not be found in AzureAD through Microsoft Graph for the displayname: $GroupDisplayName. Use -Force paramater to automatically create
                Groups from Json in AzureAD. "
            }  
            if ($Force -eq $true ) {
                write-host "Creating $GroupDisplayName"
                #Define group JSON template
                $GroupFile = '{
                "description": "GrpDescription",
                "displayName": "GrpDisplayName",
                "groupTypes": [
                  "Unified"
                ],
                "mailEnabled": false,
                "mailNickname": "NotSet",
                "securityEnabled": true
              }'
                #Convert GroupJSON to Powershell
                $GroupPS = $GroupFile | ConvertFrom-Json
                #Fill PS object with correct Displayname and Description
                $GroupPS.displayName = $GroupDisplayName
                $GroupPS.description = $GroupDisplayName
                $GroupPS.mailNickname = $GroupDisplayName
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
            }
        }
        #Add ID to GroupGuids
        $GroupGuids += ($GroupObject.value.id)
    }
    Return $GroupGuids
}