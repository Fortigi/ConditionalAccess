function Get-AccessToken {
    <#
    .SYNOPSIS
    The Get-AccessToken command uses an App-registration in Azure Active directory to retrieve an Access token which can then be used for the other commands the App is permitted. This includes but is not
    limited to reading, creating and updating Conditional Access Polcies. 
    
    .Description
    Prerequisites
    - App registered in the target Azure Active Directory
    - Valid client secret of the App
    - The App needs to have at least the followwing Admin Consented API permissions to be used for Conditional Access policies*:
        User.Read.All
        Application.Read.All
        Group.Read.All
        Policy.Read.All
        Policy.ReadWrite.ConditionalAccess

        -Optional for automatic group creation 
        Group.Create
    
    *If you want to use the Token for other purposes you can modify the permissions to your own requirements

    .example 
    $AccessToken = Get-AccessToken -ClientID xxxx-xxxx-xxxx-xxxx -ClientSecret xxxxxxxxxxxxxxxx -TenantID xxxx-xxxx-xxxx-xxxx
    #>
    Param(
        [Parameter(Mandatory = $True)]
        [System.String]$ClientId,
        [Parameter(Mandatory = $True)]
        [System.String]$ClientSecret,       
        [Parameter(Mandatory = $True)]
        [System.String]$TenantId            
    )

    $Body = @{client_id = $ClientID; client_secret = $ClientSecret; grant_type = "client_credentials"; resource = "https://graph.microsoft.com"; }
    $OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Body $Body
    $AccessToken = $OAuthReq.access_token
    If ($AccessToken) {
        Return $AccessToken
    }
    If (!$AccessToken) { 
        Throw "Error retrieving Graph Access Token. Please validate parameter input for -ClientID, -ClientSecret and -TenantId and check API permissions of the (App Registration) client in AzureAD" 
    }
} 