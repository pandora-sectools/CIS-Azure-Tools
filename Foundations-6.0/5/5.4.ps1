# 5.4 Ensure that No Custom Subscription Administrator Roles Exist
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

# Get Subscription Info
try {
    $Subscription = az account show -o json 2>$null | ConvertFrom-Json
    if (-not $Subscription) { throw "No subscription returned."}
    $SubscriptionScope = "/subscriptions/$($Subscription.id)"
} catch {
    Write-Host "** ERROR : Unable to determine current subscription. **"
    return
}

# Fetch Custom Administrator Roles
$RolesJson = az role definition list `
    --custom-role-only true `
    -o json 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate custom Azure role definitions. **"
    return
}

$Roles = $RolesJson | ConvertFrom-Json
$RoleReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Role in @($Roles)) {

    $SubscriptionScoped = @(
        $Role.assignableScopes | Where-Object {
            $_ -eq $SubscriptionScope -or $_ -eq "/"
        }
    ).Count -gt 0

    $WildcardAction = @(
        $Role.permissions.actions | Where-Object {
            $_ -eq "*"
        }
    ).Count -gt 0

    if ($SubscriptionScoped -and $WildcardAction) {

        $RoleReport.Add([PSCustomObject]@{
            RoleName         = $Role.roleName
            RoleId           = $Role.name
            AssignableScopes = $Role.assignableScopes -join ", "
            WildcardAction   = $true
            AuditState       = "FAIL"
        })
    }
}

if (@($RoleReport).Count -gt 0) {
    Write-Host "** FAIL : Custom subscription administrator roles were found. **"

    $RoleReport |
        Format-Table RoleName, RoleId, AssignableScopes, WildcardAction, AuditState -AutoSize
}
else {
    Write-Host "** PASS : No custom subscription administrator roles were found. **"
}
