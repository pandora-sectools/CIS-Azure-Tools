# 7.13 Ensure 'HTTP2' is Set to 'Enabled' on Azure Application Gateway
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

$GatewayReport = [System.Collections.Generic.List[Object]]::new()

$Gateways = az network application-gateway list `
    -o json | ConvertFrom-Json

if (-not $Gateways) {
    Write-Host "** PASS : No Azure Application Gateways found. **"
    return
}

foreach ($Gateway in $Gateways) {

    $Obj = [PSCustomObject]@{
        GatewayName   = $Gateway.name
        ResourceGroup = $Gateway.resourceGroup
        HTTP2Enabled  = $Gateway.enableHttp2
        AuditState    = "PASS"
    }

    if ($Obj.HTTP2Enabled -ne $true) { $Obj.AuditState = "FAIL" }

    $GatewayReport.Add($Obj)
}

$FailingGateways = $GatewayReport | Where-Object {
    $_.AuditState -eq "FAIL"
}

if (@($FailingGateways).Count -gt 0) {
    Write-Host "** FAIL : Azure Application Gateways found with HTTP2 disabled. **"
    $FailingGateways | Format-Table GatewayName, ResourceGroup, HTTP2Enabled, AuditState -AutoSize
} else {
    Write-Host "** PASS : HTTP2 is enabled on all Azure Application Gateways. **"
    $GatewayReport | Format-Table GatewayName, ResourceGroup, HTTP2Enabled, AuditState -AutoSize
}
