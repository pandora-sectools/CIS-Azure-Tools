# Microsoft Azure Cloud PowerShell 7 Test Environment Setup

### Install KVM/libVirt drivers

Install via binary installers:

- [PS7 - PS5 causes some issues](https://github.com/PowerShell/PowerShell/releases/download/v7.6.4/PowerShell-7.6.4-win-x64.msi)
- [AzureCLI - We do not use AZ Powershell, it sucks](https://aka.ms/installazurecliwindowsx64)
- [WinFSP - Helpful for Shared Folders](https://winfsp.dev/rel/)
- [VirtIO - Windows Guest Tools](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

Can also be installed with Winget:

- `winget install --exact --id Microsoft.PowerShell --source winget`
- `winget install --exact --id Microsoft.AzureCLI --source winget`
- `winget install --exact --id RedHat.VirtIO`
- `winget install --exact --id WinFsp.WinFsp`


### Configure Terminal

Scripts will not work by default. Requires setup.

- After installing PowerShell 7, make sure to set it as the default in Windows Terminal.
- Set the execution policy to bypass restrictions for testing scripts:
  - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy bypass -Force`


### Uninstall ALL PS5 & PS7 Microsoft 365 PowerShell Modules

Remove old or conflicting module versions. 

- Remove all AZ Modules. We use AzureCLI instead, and having both installed causes problems.
  - `Get-InstalledPSResource -Name Az.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
  - `Uninstall-PSResource -Name Az`
- Graph modules removal
  - `Get-InstalledPSResource -Name Microsoft.Graph.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
  - `Uninstall-PSResource -Name Microsoft.Graph`
- ExchangeOnlineManagement Removal
  - `Get-InstalledPSResource -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
- ExchangePowerShell Removal
  - `Uninstall-PSResource -Name ExchangePowerShell`
  
### Reinstall PowerShell Modules

We need to pin module versions to those used to validate the CIS 6.0 PowerShell snippets.
This avoids a multitude of bugs caused by the awful Module Code (e.g. Microsoft.IdentityModel conflict)

Do **NOT** reinstall any modules. Pin the given versions **ONLY.** newer versions have bugs and do not work. 

- PSResourceGet
  - `Install-PSResource -Name Microsoft.PowerShell.PSResourceGet -Reinstall -TrustRepository -ErrorAction Continue`
- Exchange Online Management **3.9.2**
  - `Install-PSResource -Name ExchangeOnlineManagement -Version 3.9.2 -Scope CurrentUser -TrustRepository -ErrorAction Continue`
- Microsoft Teams **7.7.0**
  - `Install-PSResource -Name MicrosoftTeams -Version 7.7.0 -Scope CurrentUser -TrustRepository -ErrorAction Continue`
- SharePoint Online **16.0.27111.12000**
  - `Install-PSResource -Name Microsoft.Online.SharePoint.PowerShell -Version 16.0.27111.12000 -TrustRepository -ErrorAction Continue`
- Microsoft 365 DSC **1.26.812.1**
  - `Install-PSResource -Name Microsoft365DSC -TrustRepository -ErrorAction Continue`
- Microsoft PnP.Powershell
  - `Install-PSResource -Name PnP.PowerShell -Version 3.1.0 -TrustRepository -ErrorAction Continue`


# Allow Dynamic Extension install
az config set extension.dynamic_install_allow_preview=true

# Install Azure Extensions when needed
az config set extension.use_dynamic_install=yes_without_prompt


# Install AZ Databricks if missing
if (-not $(az extension show --name databricks 2>$null | ConvertFrom-Json)) {
    Write-Host "Installing Azure CLI Databricks extension..."
    az extension add --name databricks --only-show-errors
}
