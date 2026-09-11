# 9.3.8 Ensure that 'Allow Blob Anonymous Access' is Set to 'Disabled' (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$BlobAnonymousAccessReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        StorageAccount         = $StorageAccount.name
        ResourceGroup          = $StorageAccount.resourceGroup
        AllowBlobPublicAccess  = $StorageAccount.allowBlobPublicAccess
        AuditState             = "PASS"
    }

    if ($Obj.AllowBlobPublicAccess -ne $false) {
        $Obj.AuditState = "FAIL"
    }

    $BlobAnonymousAccessReport.Add($Obj)
}

$FailingAccounts = $BlobAnonymousAccessReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with Blob anonymous access enabled. **"
    $FailingAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts have Blob anonymous access disabled. **"
    $BlobAnonymousAccessReport | Format-Table
}
