# CIS-365-Tools - Helper tools for CIS Benchmarking


**NOTE** The scripts in this repoistory are untested and sometimes incomplete. Not all Benchmark versions
have a working published script.

Current Supported CIS benchmark versions:
- **Foundations 6.0 Level 1**


### Required Testing Tools
CLI Programs:
- Windows Terminal
- Microsoft.AzureCLI

- PowerShell Modules:
    - PnP.PowerShell                                                         3.1.0
    - Packagemangement
    - PowershellGet
    - ExchangeOnlineManagement                                               3.9.2
    - Microsoft.Graph.Authentication                                        2.36.1
    - Microsoft.Graph.Applications                                          2.36.1
    - Microsoft.Graph.DeviceManagement                                      2.36.1
    - Microsoft.Graph.Groups                                                2.36.1
    - Microsoft.Graph.Identity.DirectoryManagement                          2.36.1
    - Microsoft.Graph.Identity.Governance                                   2.36.1
    - Microsoft.Graph.Identity.Signins                                      2.36.1
    - Microsoft.Graph.Reports                                               2.36.1
    - Microsoft.Graph.Users                                                 2.36.1

**NOTE** Be sure to remove all Az powershell modules. they conflict with the AzureCLI Tools
and can cause these scripts to not run correctly! Remove with this command:

```powershell
    Get-Module -ListAvailable "Az.*" | ForEach {Uninstall-Module -Name $_.Name}

```


### Required Test User Permissions

Required Roles:
- Global Reader
- Security Reader
- Subscription Contributor
- Graph Data Connect Administrator
- Privileged Role Administrator \[1\]
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
