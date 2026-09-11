# 5.1.1 Ensure that 'security defaults' is Enabled in Microsoft Entra ID (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

$DefaultsEnabled = az rest --method get `
    --url 'https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy' `
    --query "isEnabled"

$DefaultsEnabled | fl

if ($DefaultsEnabled -eq "true") {
    Write-Host "** PASS : Security defaults are enabled. **"
} elseif ($DefaultsEnabled -eq "false") {
    Write-Host "** FAIL : Security defaults are disabled. **"
} else {
    Write-Host "** MANUAL : Unable to determine security defaults state. **"
}
