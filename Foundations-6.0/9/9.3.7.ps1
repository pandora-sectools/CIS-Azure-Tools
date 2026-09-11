# 9.3.7 Ensure 'Cross Tenant Replication' is Not Enabled (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$CrossTenantReplicationReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount             = $StorageAccount.name
        ResourceGroup              = $StorageAccount.resourceGroup
        CrossTenantReplication     = $StorageAccount.allowCrossTenantReplication
        AuditState                 = "PASS"
    }

    if ($Obj.CrossTenantReplication -ne $false) {
        $Obj.AuditState = "FAIL"
    }

    $CrossTenantReplicationReport.Add($Obj)
}

$FailingAccounts = $CrossTenantReplicationReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with cross-tenant replication enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have cross-tenant replication disabled. **"
    $CrossTenantReplicationReport | Format-Table
}
