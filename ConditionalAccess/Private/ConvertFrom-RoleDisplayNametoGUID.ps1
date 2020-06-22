function ConvertFrom-RoleDisplayNametoGUID { 
    param
    (
        [Parameter(Mandatory = $false)]
        [array]$RoleDisplayNames,
        [Parameter(Mandatory = $true)]
        $accessToken 
    )
    
    [array]$RoleGuids = $null

    #Default Roles don't show up in Graph untill they are activated / used. You do however want to be able to set them in policy even if you don't use them yet. GUIDs are always the same.
    $DefaultRolesJosn = '[
        {
            "ObjectId":  "00d4c635-0959-4014-ba42-b54494cf5d2d",
            "DisplayName":  "Guest Inviter"
        },
        {
            "ObjectId":  "08d8f31f-9d75-421e-ab41-bb671fa2a3a4",
            "DisplayName":  "Teams Communications Support Engineer"
        },
        {
            "ObjectId":  "14d26fb8-8635-4f94-ac28-f494a8e211cd",
            "DisplayName":  "Privileged Authentication Administrator"
        },
        {
            "ObjectId":  "160aea82-ae83-4ae3-8365-0c6de943755b",
            "DisplayName":  "External ID User Flow Administrator"
        },
        {
            "ObjectId":  "1a667ab1-f22a-48b6-b673-54c20b929e12",
            "DisplayName":  "Search Administrator"
        },
        {
            "ObjectId":  "1baebecb-5f05-473d-8b8d-e4c24473bbcb",
            "DisplayName":  "Security Reader"
        },
        {
            "ObjectId":  "1e128f3f-62a4-402a-99eb-0f7df77d340a",
            "DisplayName":  "Security Operator"
        },
        {
            "ObjectId":  "1fd38236-c948-4759-87b9-e8aa8d189f78",
            "DisplayName":  "Teams Service Administrator"
        },
        {
            "ObjectId":  "20313b16-8130-4fe6-ba3d-c213e0ec853b",
            "DisplayName":  "Teams Communications Administrator"
        },
        {
            "ObjectId":  "24b95023-3d08-49af-8dee-210f52b9730b",
            "DisplayName":  "Authentication Administrator"
        },
        {
            "ObjectId":  "26b69c66-c312-4418-8867-b78413702c29",
            "DisplayName":  "Groups Administrator"
        },
        {
            "ObjectId":  "284e2be8-ac31-443b-8971-a3a9cb80d0d3",
            "DisplayName":  "Printer Administrator"
        },
        {
            "ObjectId":  "29ad642e-70e5-43a5-b127-f9eaf787ade1",
            "DisplayName":  "Exchange Service Administrator"
        },
        {
            "ObjectId":  "3394bbce-d2ec-4dfc-8343-5bc4a00c19c0",
            "DisplayName":  "Customer LockBox Access Approver"
        },
        {
            "ObjectId":  "396ea1ff-c900-415d-b641-5fa41b077c14",
            "DisplayName":  "Lync Service Administrator"
        },
        {
            "ObjectId":  "3c7025e9-98b7-443e-a0fc-4bb797352027",
            "DisplayName":  "Cloud Application Administrator"
        },
        {
            "ObjectId":  "3d87bac3-0e03-46a7-b07e-91f41ecfd257",
            "DisplayName":  "External ID User Flow Attribute Administrator"
        },
        {
            "ObjectId":  "44e2961c-d8f4-45f6-aaec-116a175754f6",
            "DisplayName":  "Hybrid Identity Administrator"
        },
        {
            "ObjectId":  "450f195b-f79a-4cc4-bd37-660d833119a2",
            "DisplayName":  "Cloud Device Administrator"
        },
        {
            "ObjectId":  "48e4b9c9-9981-4320-b141-e9d5d583542b",
            "DisplayName":  "Global Reader"
        },
        {
            "ObjectId":  "53d32e73-7ced-47ba-98bb-b36cfa6575f4",
            "DisplayName":  "Search Editor"
        },
        {
            "ObjectId":  "59c3380a-b855-4db5-9205-6e27455b0f79",
            "DisplayName":  "Printer Technician"
        },
        {
            "ObjectId":  "611e32cd-26b5-4518-89b7-2b96f9997374",
            "DisplayName":  "Network Administrator"
        },
        {
            "ObjectId":  "62085aa5-94bc-43a8-a714-97aed8e91a5d",
            "DisplayName":  "Billing Administrator"
        },
        {
            "ObjectId":  "64a4aa7e-9f39-46ec-9d48-d31e52fed0cb",
            "DisplayName":  "SharePoint Service Administrator"
        },
        {
            "ObjectId":  "656b2e8f-d9aa-4df6-a27d-b49951be1c14",
            "DisplayName":  "Compliance Data Administrator"
        },
        {
            "ObjectId":  "6cd88fe5-5487-41b0-9853-e2bc6ca6e370",
            "DisplayName":  "Application Developer"
        },
        {
            "ObjectId":  "6ec02b10-330e-4906-b0a2-cba3ea0471d2",
            "DisplayName":  "Power BI Service Administrator"
        },
        {
            "ObjectId":  "7f2254d0-6a67-4b2b-b2e9-c984bd3abf85",
            "DisplayName":  "Service Support Administrator"
        },
        {
            "ObjectId":  "7f4698c3-7dbd-4412-8734-5bb9d6019561",
            "DisplayName":  "Password Administrator"
        },
        {
            "ObjectId":  "86ec1c03-e60c-45db-93f2-dbae93aca008",
            "DisplayName":  "Compliance Administrator"
        },
        {
            "ObjectId":  "8770c270-8d55-4556-8d97-54bff930b2d3",
            "DisplayName":  "B2C IEF Policy Administrator"
        },
        {
            "ObjectId":  "8b27dc5d-3e36-4125-84d4-d46097b31910",
            "DisplayName":  "Security Administrator"
        },
        {
            "ObjectId":  "9016b25c-6ec8-4fef-a40e-376d68b081af",
            "DisplayName":  "Intune Service Administrator"
        },
        {
            "ObjectId":  "90beff49-74e5-4693-af3b-e3cebf2daf68",
            "DisplayName":  "External Identity Provider Administrator"
        },
        {
            "ObjectId":  "965ac1c6-5156-4a56-b131-25527351b489",
            "DisplayName":  "User Account Administrator"
        },
        {
            "ObjectId":  "b789749a-a16d-4b60-abdc-02f380602ea4",
            "DisplayName":  "Teams Communications Support Specialist"
        },
        {
            "ObjectId":  "b822b5e5-7cd1-4ece-901a-f1913ff53f05",
            "DisplayName":  "Office Apps Administrator"
        },
        {
            "ObjectId":  "bb1813d6-28d9-49a4-8d18-f32a12207511",
            "DisplayName":  "B2C IEF Keyset Administrator"
        },
        {
            "ObjectId":  "bc2dc299-a160-4c53-883e-d16b0481e281",
            "DisplayName":  "Azure Information Protection Administrator"
        },
        {
            "ObjectId":  "c3fb5df1-d9da-437e-a30a-ec18c6bcb8ea",
            "DisplayName":  "Message Center Privacy Reader"
        },
        {
            "ObjectId":  "c4043186-ea3c-4874-b6e5-69d526c9d8fe",
            "DisplayName":  "Power Platform Administrator"
        },
        {
            "ObjectId":  "cb640c51-2864-4444-b831-fb0c57065672",
            "DisplayName":  "Reports Reader"
        },
        {
            "ObjectId":  "d4d7cc69-991e-42d8-bb0f-3da3203efa3c",
            "DisplayName":  "Desktop Analytics Administrator"
        },
        {
            "ObjectId":  "d5d879a5-a051-4d09-a9b5-26251183e042",
            "DisplayName":  "Azure DevOps Administrator"
        },
        {
            "ObjectId":  "d6b6c5c2-e388-42fd-94a6-540b06883a69",
            "DisplayName":  "Message Center Reader"
        },
        {
            "ObjectId":  "d91dcdee-5d7d-474e-9bd5-393da18d32d9",
            "DisplayName":  "Privileged Role Administrator"
        },
        {
            "ObjectId":  "da39430e-1e15-4c1d-87e8-5c2fe3985bd2",
            "DisplayName":  "Conditional Access Administrator"
        },
        {
            "ObjectId":  "db48b000-68ce-48be-a94f-558690cfab53",
            "DisplayName":  "Kaizala Administrator"
        },
        {
            "ObjectId":  "dd4e26eb-7767-4eb7-b48b-f60635c210b9",
            "DisplayName":  "Application Administrator"
        },
        {
            "ObjectId":  "e5ba5e0e-c3aa-4b80-b89a-d0afdc1efe60",
            "DisplayName":  "License Administrator"
        },
        {
            "ObjectId":  "e6f40909-baad-45dc-99e6-e94c6f966f48",
            "DisplayName":  "Company Administrator"
        },
        {
            "ObjectId":  "eaea80ed-52c6-4eb4-9a11-55dcb345659e",
            "DisplayName":  "CRM Service Administrator"
        },
        {
            "ObjectId":  "f480d315-ef3a-4568-bfb1-78be6dcc6e29",
            "DisplayName":  "Directory Readers"
        },
        {
            "ObjectId":  "fbd0bbd7-c485-488f-a95a-40f01a61a329",
            "DisplayName":  "Helpdesk Administrator"
        }
    ]'

    $DefaultRoles = $DefaultRolesJosn | ConvertFrom-Json

    foreach ($RoleDisplayName in $RoleDisplayNames) {

        #Find role in Default roles set.
        $Found = $DefaultRoles | Where-Object { $_.DisplayName -eq $RoleDisplayName }

        If ($Found) {
            $RoleGuids += ($Found.ObjectId) 
        }
        Else {
            $URI = "https://graph.microsoft.com/beta/directoryRoles?" + '$filter' + "=displayName eq '$RoleDisplayName'"
            $RoleObject = Invoke-RestMethod -Method Get -Uri $URI -Headers @{"Authorization" = "Bearer $accessToken" } 
            If (!$RoleObject.value) {
                throw "Role $RoleDisplayName is not found."
            }
            $RoleGuids += ($RoleObject.value.id) 
        } 
        
    }
    Return $RoleGuids
}
