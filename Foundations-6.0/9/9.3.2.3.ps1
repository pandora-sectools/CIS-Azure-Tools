# 9.3.2.3 Ensure Default Network Access Rule for Storage Accounts is Set to Deny (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$NetworkRuleReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount = $StorageAccount.name
        ResourceGroup  = $StorageAccount.resourceGroup
        DefaultAction  = $StorageAccount.networkRuleSet.defaultAction
        AuditState     = "PASS"
    }

    if ($Obj.DefaultAction -eq "Allow") {
        $Obj.AuditState = "FAIL"
    }

    $NetworkRuleReport.Add($Obj)
}

$FailingAccounts = $NetworkRuleReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with default network access rule set to Allow. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : No storage accounts have default network access rule set to Allow. **"
    $NetworkRuleReport | Format-Table
}
