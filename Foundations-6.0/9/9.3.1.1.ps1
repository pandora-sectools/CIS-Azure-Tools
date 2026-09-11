# 9.3.1.1 Ensure That 'Enable key rotation reminders' is Enabled for Each Storage Account (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$KeyRotationReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Account = az storage account show `
        --resource-group $StorageAccount.resourceGroup `
        --name $StorageAccount.name `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount              = $Account.name
        ResourceGroup               = $Account.resourceGroup
        KeyExpirationPeriodInDays   = $Account.keyPolicy.keyExpirationPeriodInDays
        AuditState                  = "PASS"
    }

    if (-not $Obj.KeyExpirationPeriodInDays) { $Obj.AuditState = "FAIL" }
    if ($Obj.KeyExpirationPeriodInDays -gt 90) { $Obj.AuditState = "FAIL" }

    $KeyRotationReport.Add($Obj)
}

$FailingAccounts = $KeyRotationReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found without key rotation reminders set to 90 days or less. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have key rotation reminders enabled. **"
    $KeyRotationReport | Format-Table
}
