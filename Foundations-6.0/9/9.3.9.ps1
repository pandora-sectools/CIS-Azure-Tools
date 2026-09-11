# 9.3.9 Ensure Azure Resource Manager Delete Locks are Applied to Azure Storage Accounts (Manual)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$LockReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Locks = az lock list `
        --resource-group $StorageAccount.resourceGroup `
        --resource-name $StorageAccount.name `
        --resource-type "Microsoft.Storage/storageAccounts" `
        -o json | ConvertFrom-Json

    $DeleteLocks = $Locks | Where-Object {
        $_.level -eq "CanNotDelete"
    }

    $Obj = [PSCustomObject]@{
        StorageAccount       = $StorageAccount.name
        ResourceGroup        = $StorageAccount.resourceGroup
        DeleteLockExists     = @($DeleteLocks).Count -gt 0
        LockCount            = @($DeleteLocks).Count
        AuditState           = "PASS"
    }

    if ($Obj.DeleteLockExists -ne $true) { $Obj.AuditState = "PARTIAL" }
    if ($Obj.DeleteLockExists -eq $false) { $Obj.AuditState = "FAIL" }

    $LockReport.Add($Obj)
}

$LocksDisabled = $LockReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($LocksDisabled).Count -gt 0) {
    Write-Host "`n** FAIL : Delete Locks are missing for some Storage accounts. Please Review. **"
    $LocksDisabled | Format-Table
} else {
    Write-Host "`n** PASS : All storage accounts have Delete locks applied. **"
    $LockReport | Format-Table
}
