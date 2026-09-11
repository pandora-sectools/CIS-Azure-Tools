# Test Account setup

To setup a test account, the following permissions are required.

### Required Test User Permissions

Required Roles:
- Global Reader
- Security Reader
- Subscription Contributor
- Graph Data Connect Administrator
- Privileged Role Administrator \[1\]
~~- Teams Reader~~
~~- Reports Reader~~
~~- SharePoint Administrator~~
~~- Exchange Administrator~~
~~- InTune Administrator / Intune Read Only Operator~~
~~- View-Only Organization Management~~
- Key Vault Crypto User
- Key Vault Secrets User

MGGraph Permissions:
- User.Read.All
- Group.Read.All
- GroupMember.Read.All
- Policy.Read.All
- Organization.Read.All
- Application.Read.All
- RoleManagement.Read.Directory
- AuditLog.Read.All
~~- Directory.Read.All~~
~~- Domain.Read.All~~
~~- UserAuthenticationMethod.Read.All~~
~~- OrgSettings-Forms.Read.All~~
~~- OrgSettings-AppsAndServices.Read.All~~
~~- DeviceManagementConfiguration.Read.All~~
~~- DeviceManagementManagedDevices.Read.All~~
~~- DeviceManagementServiceConfig.Read.All~~
~~- OnPremDirectorySynchronization.Read.All~~

Azure KeyVault Permissions:
- KeyVault.Secrets.List
- KeyVault.Secrets.Get
- KeyVault.Certificate.List
- KeyVault.Certificate.Get
 

For Key Vaults using Azure RBAC:

- Open the target Key Vault in the Azure Portal.
- Select `Access Control (IAM)`.
- Select `Add` >> `Add role assignment`.
- Select the minimum Key Vault role specified by the individual CIS recommendation.
- Assign it to the test account or another appropriately narrow assessment principal.
- Prefer a PIM-eligible/time-bound assignment where available.
- Select Review + assign.
- Repeat for each Key Vault requiring data plane assessment.

For Key Vaults using legacy Access Policies:

Open the target Key Vault.
Select Access policies.
Create a new access policy.
Enable only the Key, Secret, or Certificate permissions specified by the individual CIS recommendation.
Assign the policy to the test account or appropriately narrow assessment principal.
Create the policy.
Repeat for each applicable legacy Key Vault.



\[1\] An annoying issue with mordern CIS testing is the incessant blocking of powershell tools by Entra. There are a couple ways to get around this issue:
- Make the test account a Global Admin. Quite risky.
- Request Admin Consent for every single Entra block. Wastes a ton of time, annoys the admin.
- Make the test account a Privleged Role Administrator.

The most convenient choice is to give Role Admin, so we do that. Once permissions are configured, make sure that Role admin has access to Application Consent Workflow:
- Go to [https://entra.microsoft.com](https://entra.microsoft.com)
- Select `Enterprise Apps` in the navigation bar 
- `Consent and Permissions` in the sidebar
- Select `Admin Consent Settings`
- select `Roles (Preview)`
- Search for `Privileged Role Administrator`
- Add Role to Admin Consent reviewers.


\[2\] Key Vault data-plane permissions must be configured individually on each Key Vault being assessed. For RBAC-enabled vaults, assign the required Key Vault RBAC roles:

- Open Azure Portal
- Goto `Key Vaults`.
- Select a subscription.
- for each KeyVault in the subscription; 
    - Select the Key Vault.
    - Select `Access Control (IAM)`.
    - Assign the Required Roles.


For legacy Access Policy vaults, assign the required Get/List permissions through Key Vault → Access policies.

These permissions provide access to sensitive Key Vault data and should be time-bound using PIM where possible and removed immediately after testing.