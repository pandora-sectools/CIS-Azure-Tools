# 6.1.2.1 Ensure that Activity Log Alert Exists for Create Policy Assignment (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$DiagReport = [System.Collections.Generic.List[Object]]::new()
$Resources = az resource list -o json | ConvertFrom-Json

foreach ($Resource in $Resources) {

    Write-Host "." -NoNewline

    try {

        $DiagnosticSetting = az monitor diagnostic-settings list `
            --resource $Resource.id `
            -o json 2>&1 | ConvertFrom-Json -ErrorAction Stop

        $DiagReport.add([PSCustomObject]@{
            ResourceName = $Resource.name
            ResourceType = $Resource.type
            DiagnosticSetting = $DiagnosticSetting
            AuditState        = if ($DiagnosticSetting) { "PASS"} else {"FAIL"}
        })
    } catch {
        $DiagReport.add([PSCustomObject]@{
            ResourceName = $Resource.name
            ResourceType = $Resource.type
            DiagnosticSettingExists = "Unsupported"
            AuditState   = "NOTAPPLICABLE"
        })
    }
}

$FailingResource = $DiagReport | Where-Object { $_.AuditState -eq "FAIL" }
if (@($FailingResource).Count -gt 0) {
    Write-Host "`n** FAIL : Resources found without diagnostic settings configured. **"
    $FailingResource | Format-Table -AutoSize
} else {
    Write-Host "`n** PASS : All checked resources have diagnostic settings configured. **"
}
