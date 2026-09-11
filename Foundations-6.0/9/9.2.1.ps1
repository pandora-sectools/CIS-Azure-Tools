# 9.2.1 Ensure That Soft Delete for Blobs on Azure Blob Storage Storage Accounts is Enabled (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$BlobSoftDeleteReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $DeletePolicy = az storage blob service-properties delete-policy show `
        --account-name $StorageAccount.name `
        --auth-mode login `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount    = $StorageAccount.name
        ResourceGroup     = $StorageAccount.resourceGroup
        SoftDeleteEnabled = $DeletePolicy.enabled
        RetentionDays     = $DeletePolicy.days
        AuditState        = "PASS"
    }

    if ($Obj.SoftDeleteEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($null -eq $Obj.RetentionDays) { $Obj.AuditState = "FAIL" }

    $BlobSoftDeleteReport.Add($Obj)
}

$FailingAccounts = $BlobSoftDeleteReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found without blob soft delete enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have blob soft delete enabled. **"
    $BlobSoftDeleteReport | Format-Table
}