# 9.1.1 Ensure Soft Delete for Azure File Shares is Enabled (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$ShareSoftDeleteReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $FileServiceProperties = az storage account file-service-properties show `
        --resource-group $StorageAccount.resourceGroup `
        --account-name $StorageAccount.name `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount          = $StorageAccount.name
        ResourceGroup           = $StorageAccount.resourceGroup
        SoftDeleteEnabled       = $FileServiceProperties.shareDeleteRetentionPolicy.enabled
        RetentionDays           = $FileServiceProperties.shareDeleteRetentionPolicy.days
        AuditState              = "PASS"
    }

    if ($Obj.SoftDeleteEnabled -ne $true) {$Obj.AuditState = "FAIL"}
    if ($Obj.RetentionDays -lt 1) {$Obj.AuditState = "FAIL"}
    if($Obj.RetentionDays -gt 365) {$Obj.AuditState = "FAIL"}
    $ShareSoftDeleteReport.Add($Obj)
}


$FailingAccounts = $ShareSoftDeleteReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts with file shares found without valid soft delete configuration. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts with file shares have soft delete enabled with valid retention. **"
    $ShareSoftDeleteReport | Format-Table #StorageAccount,SoftDeleteEnabled,RetentionDays,AuditState
}