# 9.2.2 Ensure that Soft Delete for Containers on Azure Blob Storage Storage Accounts is Enabled (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$ContainerSoftDeleteReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Policy = az storage account blob-service-properties show `
        --resource-group $StorageAccount.resourceGroup `
        --account-name $StorageAccount.name `
        --query containerDeleteRetentionPolicy `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount    = $StorageAccount.name
        ResourceGroup     = $StorageAccount.resourceGroup
        SoftDeleteEnabled = $Policy.enabled
        RetentionDays     = $Policy.days
        AuditState        = "PASS"
    }

    if ($Obj.SoftDeleteEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($null -eq $Obj.RetentionDays) { $Obj.AuditState = "FAIL" }

    $ContainerSoftDeleteReport.Add($Obj)
}

$FailingAccounts = $ContainerSoftDeleteReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found without container soft delete enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have container soft delete enabled. **"
    $ContainerSoftDeleteReport | Format-Table
}
