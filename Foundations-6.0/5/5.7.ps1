# 5.7 Ensure there are between 2 and 3 Subscription Owners
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}


# Get Subscription Info
try {
    $Subscription = az account show -o json 2>$null | ConvertFrom-Json
    if (-not $Subscription) { throw "No subscription returned." }
    $SubscriptionScope = "/subscriptions/$($Subscription.id)"
} catch {
    Write-Host "** ERROR : Unable to determine current subscription. **"
    return
}


# Get Owner role assignments
$OwnersJson = az role assignment list `
    --role "Owner" `
    --scope $SubscriptionScope `
    --include-inherited `
    -o json 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Subscription Owner role assignments. **"
    return
}

$Owners = @($OwnersJson | ConvertFrom-Json)
$OwnerReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Owner in $Owners) {

    $OwnerReport.Add([PSCustomObject]@{
        PrincipalName = $Owner.principalName
        PrincipalType = $Owner.principalType
        PrincipalId   = $Owner.principalId
        Scope         = $Owner.scope
    })
}

$OwnerCount = @($OwnerReport).Count
if ($OwnerCount -lt 2) {
    Write-Host "** FAIL : Only $OwnerCount Subscription Owner(s) found. Between 2 and 3 are required. **"
    $OwnerReport | Format-Table PrincipalName, PrincipalType, Scope -AutoSize
} elseif ($OwnerCount -gt 3) {
    Write-Host "** FAIL : $OwnerCount Subscription Owners found. A maximum of 3 is permitted. **"
    $OwnerReport | Format-Table PrincipalName, PrincipalType, Scope -AutoSize

} else {
    Write-Host "** PASS : $OwnerCount Subscription Owners found. **"
    $OwnerReport | Format-Table PrincipalName, PrincipalType, Scope -AutoSize
}
