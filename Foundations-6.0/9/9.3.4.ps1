# 9.3.4 Ensure that 'Secure transfer required' is Set to 'Enabled' (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$HttpsReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount        = $StorageAccount.name
        ResourceGroup         = $StorageAccount.resourceGroup
        EnableHttpsTrafficOnly = $StorageAccount.enableHttpsTrafficOnly
        AuditState            = "PASS"
    }

    if ($Obj.EnableHttpsTrafficOnly -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    $HttpsReport.Add($Obj)
}

$FailingAccounts = $HttpsReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with Secure Transfer Required disabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have Secure Transfer Required enabled. **"
    $HttpsReport | Format-Table
}
