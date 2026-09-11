# 9.3.3.1 Ensure that 'Default to Microsoft Entra authorization in the Azure portal' is Set to 'Enabled' (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$OAuthReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount               = $StorageAccount.name
        ResourceGroup                = $StorageAccount.resourceGroup
        DefaultToOAuthAuthentication = $StorageAccount.defaultToOAuthAuthentication
        AuditState                   = "PASS"
    }

    if ($Obj.DefaultToOAuthAuthentication -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    $OAuthReport.Add($Obj)
}

$FailingAccounts = $OAuthReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found without default Microsoft Entra authorization enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts default to Microsoft Entra authorization in the Azure portal. **"
    $OAuthReport | Format-Table
}
