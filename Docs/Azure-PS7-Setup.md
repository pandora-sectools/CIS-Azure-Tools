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



# Allow Dynamic Extension install
az config set extension.dynamic_install_allow_preview=true

# Install Azure Extensions when needed
az config set extension.use_dynamic_install=yes_without_prompt


# Install AZ Databricks if missing
if (-not $(az extension show --name databricks 2>$null | ConvertFrom-Json)) {
    Write-Host "Installing Azure CLI Databricks extension..."
    az extension add --name databricks --only-show-errors
}
