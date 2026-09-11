# 6.1.1.1 Ensure that a 'Diagnostic Setting' Exists for Subscription Activity Logs
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

# Get Subscription Info
try {
    $Subscription = az account show -o json 2>$null | ConvertFrom-Json
    if (-not $Subscription) { throw "No subscription returned."}
} catch {
    Write-Host "** ERROR : Unable to determine current subscription. **"
    return
}

# Get Subscription Diagnostic Settings
$DiagnosticJson = az monitor diagnostic-settings subscription list `
    --subscription $Subscription.id `
    -o json 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Subscription Diagnostic Settings. **"
    return
}

$DiagnosticResponse = $DiagnosticJson | ConvertFrom-Json
$DiagnosticSettings = @($DiagnosticResponse.value)
$DiagnosticReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Setting in $DiagnosticSettings) {

    $Obj = [PSCustomObject]@{
        Name         = $Setting.name
        Destinations = [System.Collections.Generic.List[String]]::new()
    }

    if ($Setting.workspaceId) { $Obj.Destinations.add("Log Analytics") }
    if ($Setting.storageAccountId) { $Obj.Destinations.add("Storage Account") }
    if ($Setting.eventHubAuthorizationRuleId) { $Obj.Destinations.add("Event Hub") }
    if ($Setting.marketplacePartnerId) { $Obj.Destinations.add("Marketplace Partner") }
    
    $DiagnosticReport.Add($Obj)
}

if (@($DiagnosticReport).Count -gt 0) {
    Write-Host "** PASS : Subscription Activity Log Diagnostic Setting exists. **"
    $DiagnosticReport | Format-Table Name, Destinations -AutoSize
} else {
    Write-Host "** FAIL : No Diagnostic Setting exists for Subscription Activity Logs. **"
}
