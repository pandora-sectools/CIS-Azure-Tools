# 9.3.6 Ensure the 'Minimum TLS version' for Storage Accounts is Set to 'Version 1.2' (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$TlsReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount    = $StorageAccount.name
        ResourceGroup     = $StorageAccount.resourceGroup
        MinimumTlsVersion = $StorageAccount.minimumTlsVersion
        AuditState        = "PASS"
    }

    if ($Obj.MinimumTlsVersion -ne "TLS1_2") {
        $Obj.AuditState = "FAIL"
    }

    $TlsReport.Add($Obj)
}

$FailingAccounts = $TlsReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with Minimum TLS version not set to TLS 1.2. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have Minimum TLS version set to TLS 1.2. **"
    $TlsReport | Format-Table
}
