# 9.3.1.2 Ensure That Storage Account Access keys are Periodically Regenerated (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$KeyRegenReport = [System.Collections.Generic.List[Object]]::new()
$StorageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($StorageAccount in $StorageAccounts) {

    Write-Host "." -NoNewline

$RegenEvents = az monitor activity-log list `
    --namespace Microsoft.Storage `
    --offset 90d `
    --resource-id $StorageAccount.id `
    -o json | ConvertFrom-Json |
    Where-Object {
        $_.authorization.action -like "*regenerateKey*" -and
        $_.status.value -eq "Succeeded"
    }

    $Obj = [PSCustomObject]@{
        StorageAccount = $StorageAccount.name
        ResourceGroup  = $StorageAccount.resourceGroup
        ResourceId     = $StorageAccount.id
        RegenEvents    = @($RegenEvents).Count
        AuditState     = "PASS"
    }

    if (@($RegenEvents).Count -lt 1) { $Obj.AuditState = "FAIL" }

    $KeyRegenReport.Add($Obj)
}

$FailingAccounts = $KeyRegenReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAccounts).Count -gt 0) {
    Write-Host "`n** FAIL : Storage accounts found without successful access key regeneration in the last 90 days. **"
    $FailingAccounts | Format-Table StorageAccount,ResourceGroup,RegenEvents
}
else {
    Write-Host "`n** PASS : All storage accounts have access key regeneration events in the last 90 days. **"
    $KeyRegenReport | Format-Table StorageAccount,ResourceGroup,RegenEvents
}
