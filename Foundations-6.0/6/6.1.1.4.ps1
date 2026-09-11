# 6.1.1.4 Ensure that Logging for Azure Key Vault is 'Enabled' (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

$KeyVaults = az keyvault list `
    --query "[].{Name:name,ResourceGroup:resourceGroup,Id:id}" `
    -o json | ConvertFrom-Json

if (-not $KeyVaults) {
    Write-Host "** NOT APPLICABLE : No Azure Key Vaults found in this subscription. **"
    return
}

$KVLoggingReport = [System.Collections.Generic.List[Object]]::new()

foreach ($KeyVault in $KeyVaults) {

    $DiagSettings = az monitor diagnostic-settings list `
        --resource "$($KeyVault.Id)" `
        -o json | ConvertFrom-Json

    $Settings = $DiagSettings.value

    if (-not $Settings) {
        $KVLoggingReport.Add([PSCustomObject]@{
            KeyVaultName      = $KeyVault.Name
            ResourceGroup     = $KeyVault.ResourceGroup
            DiagnosticSetting = ""
            Destination       = ""
            AuditEnabled      = $false
            AllLogsEnabled    = $false
            AuditState        = "FAIL"
        })
        continue
    }
    
    foreach ($Setting in $Settings) {

        $HasDestination = -not [string]::IsNullOrWhiteSpace($Setting.storageAccountId) -or
                          -not [string]::IsNullOrWhiteSpace($Setting.workspaceId) -or
                          -not [string]::IsNullOrWhiteSpace($Setting.eventHubAuthorizationRuleId)

        $AuditEnabled = [bool]($Setting.logs | Where-Object {
            $_.categoryGroup -eq "audit" -and $_.enabled -eq $true
        })

        $AllLogsEnabled = [bool]($Setting.logs | Where-Object {
            $_.categoryGroup -eq "allLogs" -and $_.enabled -eq $true
        })

        $KVLoggingReport.Add([PSCustomObject]@{
            KeyVaultName      = $KeyVault.Name
            ResourceGroup     = $KeyVault.ResourceGroup
            DiagnosticSetting = $Setting.name
            Destination       = if ($Setting.workspaceId) { $Setting.workspaceId } elseif ($Setting.storageAccountId) { $Setting.storageAccountId } elseif ($Setting.eventHubAuthorizationRuleId) { $Setting.eventHubAuthorizationRuleId } else { "" }
            AuditEnabled      = $AuditEnabled
            AllLogsEnabled    = $AllLogsEnabled
            AuditState        = if ($HasDestination -and $AuditEnabled -and $AllLogsEnabled) { "PASS" } else { "FAIL" }
        })
    }
}

$FailingKeyVaults = $KVLoggingReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingKeyVaults).Count -gt 0) {
    Write-Host "** FAIL : Key Vault diagnostic logging is not correctly enabled. **"
    $FailingKeyVaults | Format-List
} else {
    Write-Host "** PASS : Key Vault diagnostic logging is enabled. **"
    $KVLoggingReport | Format-List
}