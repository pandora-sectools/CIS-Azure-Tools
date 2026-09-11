# 6.1.2.9 Ensure that Activity Log Alert Exists for Create or Update Public IP Address rule (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

$PublicIPOperation = "Microsoft.Network/publicIPAddresses/write"
$AlertReport = [System.Collections.Generic.List[Object]]::new()
$Alerts = az monitor activity-log alert list `
    --query "[].{Name:name,Enabled:enabled,Condition:condition.allOf,Actions:actions}" `
    -o json | ConvertFrom-Json

if (-not $Alerts) {
    Write-Host "** FAIL : No Activity Log Alerts found. **"
    return
}

foreach ($Alert in $Alerts) {

    $Obj = [PSCustomObject]@{
        AlertName                 = $Alert.Name
        Enabled                   = $Alert.Enabled
        OperationName             = $Alert.Condition | Where-Object { $_.field -eq "operationName" }
        Actions                   = $Alert.Actions
        ActionGroupAssigned       = @($Alert.Actions.actionGroups).Count -gt 0
        AuditState                = "PASS"
    }

    if ($Obj.Enabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.OperationName.equals -notmatch $PublicIPOperation ) { $Obj.AuditState = "FAIL"}
    if (-not $Obj.ActionGroupAssigned) { $Obj.AuditState = "FAIL" }

    $AlertReport.Add($Obj)
}

$PassingAlerts = $AlertReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingAlerts).Count -gt 0) {
    Write-Host "** PASS : Activity Log Alert exists for Create or Update Public IP Address Rule. **"
    $PassingAlerts | Format-List
} else {
    Write-Host "** FAIL : No enabled Activity Log Alert found for Create or Update Public IP Address Rule with an action group. **"
    $AlertReport | Format-List
}
