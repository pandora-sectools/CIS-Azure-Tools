# 9.3.1.3 Ensure 'Allow storage account key access' for Azure Storage Accounts is 'Disabled' (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SharedKeyReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Account = az storage account show `
        --resource-group $StorageAccount.resourceGroup `
        --name $StorageAccount.name `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount       = $Account.name
        ResourceGroup        = $Account.resourceGroup
        AllowSharedKeyAccess = $Account.allowSharedKeyAccess
        AuditState           = "PASS"
    }

    if ($Obj.AllowSharedKeyAccess -ne $false) {
        $Obj.AuditState = "FAIL"
    }

    $SharedKeyReport.Add($Obj)
}

$FailingAccounts = $SharedKeyReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with shared key access enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have shared key access disabled. **"
    $SharedKeyReport | Format-Table
}