# 7.7 Ensure that Public IP Addresses are Evaluated on a Periodic Basis (Manual)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$PublicIPs = az network public-ip list | convertfrom-json
$PublicIPs | Format-Table name, ipaddress

if (($PublicIPs.ipaddress).Count -gt 0) {
    Write-Host "** PARTIAL - Please review Public IP Assignments. **"
} else {
    Write-Host "** PASS - Tenancy does not have any Public IP Assignments. **"
}
