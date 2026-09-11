# 9.1.3 Ensure 'SMB channel encryption' is Set to 'AES-256-GCM' or Higher for SMB file shares (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SmbEncryptionReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json
$OutdatedEncryption = @("AES-128-CCM", "AES-128-GCM")

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

    $FileServiceProperties = az storage account file-service-properties show `
        --resource-group $StorageAccount.resourceGroup `
        --account-name $StorageAccount.name `
        -o json | ConvertFrom-Json

    $Obj = [PSCustomObject]@{
        StorageAccount     = $StorageAccount.name
        ResourceGroup      = $StorageAccount.resourceGroup
        ChannelEncryption  = $FileServiceProperties.protocolSettings.smb.channelEncryption
        AuditState         = "PASS"
    }

    if ([string]::IsNullOrWhiteSpace($Obj.ChannelEncryption)) { $Obj.AuditState = "PARTIAL" }
    if ($Obj.ChannelEncryption -match ($OutdatedEncryption -join '|')) { $Obj.AuditState = "FAIL" }

    $SmbEncryptionReport.Add($Obj)
}

$FailingAccounts = $SmbEncryptionReport | Where-Object { $_.AuditState -eq "FAIL" }
$PartialAccounts = $SmbEncryptionReport | Where-Object { $_.AuditState -eq "PARTIAL" }
if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found with SMB channel encryption lower than AES-256-GCM. **"
    $FailingAccounts | Format-Table
} elseif (@($PartialAccounts).Count -gt 0) {
    Write-Host "`n** PARTIAL : Not all storage accounts have a minimum Channel Encryption Strength. **"
    $PartialAccounts | Format-Table
}
else {
    Write-Host "`n** PASS : All storage accounts are configured for AES-256-GCM SMB channel encryption or higher. **"
    $SmbEncryptionReport | Format-Table
}
