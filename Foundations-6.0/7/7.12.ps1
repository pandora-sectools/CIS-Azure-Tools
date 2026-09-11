# 7.12 Ensure the SSL Policy's 'Min protocol version' is Set to 'TLSv1_2' or Higher on Azure Application Gateway
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
        GatewayName        = $Gateway.name
        ResourceGroup      = $Gateway.resourceGroup
        SSLPolicyType      = $Gateway.sslPolicy.policyType
        MinProtocolVersion = $Gateway.sslPolicy.minProtocolVersion
        AuditState         = "FAIL"
    }

    if ( @("TLSv1_2", "TLSv1_3") -contains $Obj.MinProtocolVersion) { $Obj.AuditState = "PASS"}

    $GatewayReport.Add($Obj)
}

$FailingGateways = $GatewayReport | Where-Object {
    $_.AuditState -eq "FAIL"
}

if (@($FailingGateways).Count -gt 0) {
    Write-Host "** FAIL : Azure Application Gateways found with a minimum TLS protocol version below TLSv1_2. **"
    $FailingGateways | Format-Table GatewayName, ResourceGroup, SSLPolicyType, MinProtocolVersion, AuditState -AutoSize
} else {
    Write-Host "** PASS : All Azure Application Gateways have a minimum TLS protocol version of TLSv1_2 or higher. **"
    $GatewayReport | Format-Table GatewayName, ResourceGroup, SSLPolicyType, MinProtocolVersion, AuditState -AutoSize
}
