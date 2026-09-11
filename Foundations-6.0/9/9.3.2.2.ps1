# 9.3.2.2 Ensure that 'Public Network Access' is 'Disabled' for Storage Accounts (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$PublicNetworkAccessReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Account = az storage account show `
        --resource-group $StorageAccount.resourceGroup `
        --name $StorageAccount.name `
        --query "{publicNetworkAccess:publicNetworkAccess}" `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount       = $StorageAccount.name
        ResourceGroup        = $StorageAccount.resourceGroup
        PublicNetworkAccess  = $Account.publicNetworkAccess
        AuditState           = "PASS"
    }

    if ($Obj.PublicNetworkAccess -ne "Disabled") {
        $Obj.AuditState = "FAIL"
    }

    $PublicNetworkAccessReport.Add($Obj)
}

$FailingAccounts = $PublicNetworkAccessReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with public network access enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have public network access disabled. **"
    $PublicNetworkAccessReport | Format-Table
}
