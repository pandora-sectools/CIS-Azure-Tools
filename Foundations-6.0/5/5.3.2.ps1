# 5.3.2 Ensure that Guest Users are Reviewed on a Regular Basis (Manual)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

$GuestAccounts = az ad user list `
    --query "[?userType=='Guest'].{DisplayName:displayName,UPN:userPrincipalName}" `
    -o json | ConvertFrom-Json

Write-Host "Guest Accounts: [$($GuestAccounts.DisplayName -join ', ')]"
if (($GuestAccounts).Count -gt 0) {
    Write-Host "** PARTIAL - Please Review Guest Accounts. **"
} else {
    Write-Host "** PASS - No guest accounts present. **"
}
