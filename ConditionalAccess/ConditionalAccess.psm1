<#
MIT License

Copyright (c) 2019 Fortigi. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>



$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

Export-ModuleMember -Function $Public.Basename


































#DIT STUK MOET ERUIT WORDEN GEHAALD, WAS VOOR TESTEN
$PoliciesFiles = Get-ChildItem -Path .\Policy
$PolicyFile = $PoliciesFiles[0]
$PolicyJson = Get-Content -Path $PolicyFile.FullName -Raw
#TM HIER

#Create Powershell Object
$PolicyPs = $PolicyJson | ConvertFrom-Json

$Force = $true

#Define the group displayNames
[array]$InclusionGroupsGuids = Convert-GroupDisplayNameToGuid -GroupDisplayNames ($PolicyPs.conditions.users.includeGroups) -accessToken $accessToken -Force $Force
[array]$GroupDisplayNames = ($PolicyPs.conditions.users.includeGroups)
[array]$ExclusionGroupsGuids = Convert-GroupDisplayNameToGuid -GroupDisplayNames ($PolicyPs.conditions.users.excludeGroups) -accessToken $accessToken -Force $Force

$


#Clear arrays for GUIDs per each Policy file
[array]$NewInclusionGroupGuids = $null
[array]$NewExclusionGroupGuids = $null

#Haal in Graph de GUIDs bij de InclusionGroup-displayNames uit de JSON
foreach ($InclusionGroupsDisplayName in $InclusionGroupsDisplayNames) {
    $conditionalAccessURI = $null
    $InclusionGroupObject = $null
    $conditionalAccessURI = "https://graph.microsoft.com/beta/groups?" + '$filter' + "=displayName eq '$InclusionGroupsDisplayName'"
    $InclusionGroupObject = Invoke-RestMethod -Method Get -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $accessToken" } 
    if ($InclusionGroupObject.value) {
        $InclusionGroupObjectID = ($InclusionGroupObject.value.id)
        write-host "ID = $InclusionGroupObjectID for $InclusionGroupsDisplayName"
        Write-host "Converting $InclusionGroupsDisplayName to ObjectID via Graph" 
        $NewInclusionGroupGuids += $InclusionGroupObjectID
    }
    else {
        throw "Group-object could not be found in AzureAD through Microsoft Graph for the displayname: $InclusionGroupsDisplayName. Use -Force paramater to automatically create
        Groups from Json in AzureAD. " 
    }
}
   
#Haal in Graph de GUIDs bij de InclusionGroup-displayNames uit de JSON
foreach ($ExclusionGroupsDisplayName in $ExclusionGroupsDisplayNames) {
    $conditionalAccessURI = $null
    $ExclusionGroupObject = $null
    $conditionalAccessURI = "https://graph.microsoft.com/beta/groups?" + '$filter' + "=displayName eq '$ExclusionGroupsDisplayName'"
    $ExclusionGroupObject = Invoke-RestMethod -Method Get -Uri $conditionalAccessURI -Headers @{"Authorization" = "Bearer $accessToken" } 
    if ($ExclusionGroupObject.value) {
        $ExclusionGroupObjectID = ($ExclusionGroupObject.value.id)
        write-host "ID = $ExclusionGroupObjectID for $ExclusionGroupsDisplayName"
        Write-host "Converting $ExclusionGroupsDisplayName to ObjectID via Graph" 
        $NewExclusionGroupGuids += $ExclusionGroupObjectID
    }
    else { throw "Group-object could not be found in AzureAD through Microsoft Graph for the displayname: $ExclusionGroupsDisplayName" }
}

##Update Powershell-object met de gevonden GUIDs
$PolicyPs.conditions.users.includeGroups = $NewInclusionGroupGuids
$PolicyPs.conditions.users.ExcludeGroups = $NewExclusionGroupGuids

#PS object terug vertalen naar $NewPolicyJSON
$NewPolicyJson = $PolicyPS | ConvertTo-Json 

return $NewPolicyJson

}


