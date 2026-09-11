# 9.1.2 Ensure 'SMB protocol version' is Set to 'SMB 3.1.1' or Higher for SMB file shares (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SmbProtocolReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json
$OutdatedSMBProtocols = @("SMB2.1", "SMB3.0")

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $FileServiceProperties = az storage account file-service-properties show `
        --resource-group $StorageAccount.resourceGroup `
        --account-name $StorageAccount.name `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount = $StorageAccount.name
        ResourceGroup  = $StorageAccount.resourceGroup
        SMBVersions    = $FileServiceProperties.protocolSettings.smb.versions
        AuditState     = "PASS"
    }

    if ([string]::IsNullOrWhiteSpace($Obj.SMBVersions)) { $Obj.AuditState = "PARTIAL" }
    if ($Obj.SMBVersions -match ($OutdatedSMBProtocols -join '|')) { $Obj.AuditState = "FAIL" }
    $SmbProtocolReport.Add($Obj)
}

$FailingAccounts = $SmbProtocolReport | Where-Object { $_.AuditState -eq "FAIL" }
$PartialAccounts = $SmbProtocolReport | Where-Object { $_.AuditState -eq "PARTIAL" }
if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with SMB protocol versions other than SMB3.1.1. **"
    $FailingAccounts | Format-Table
} elseif (@($PartialAccounts).Count -gt 0) {
    Write-Host "`n** PARTIAL : Not all storage accounts have a minimum protocol version. **"
    $PartialAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts are configured for SMB3.1.1 only. **"
    $SmbProtocolReport | Format-Table
}
