# 5.3.3 Ensure That Use of the 'User Access Administrator' Role is Restricted
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

# Fetch User Access Administrator Assignments
$AssignmentsJson = az role assignment list `
    --all `
    --include-inherited `
    --fill-principal-name false `
    --fill-role-definition-name false `
    -o json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Azure role assignments. **"
    Write-Host $AssignmentsJson
    return
}

$xUaaRoleId = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
$RoleReport = [System.Collections.Generic.List[Object]]::new()
$Assignments = $AssignmentsJson | ConvertFrom-Json | Where-Object {
    $_.roleDefinitionId -match "/$UaaRoleId$"
}

foreach ($Assignment in @($Assignments)) {

    $RoleReport.Add([PSCustomObject]@{
        PrincipalId   = $Assignment.principalId
        PrincipalType = $Assignment.principalType
        Scope         = $Assignment.scope
        AuditState    = "PARTIAL"
    })
}

if (@($RoleReport).Count -gt 0) {
    Write-Host "** PARTIAL : Please review User Access Administrator role assignments. **"
    $RoleReport | Format-Table PrincipalId, PrincipalType, Scope, AuditState -AutoSize
} else {
    Write-Host "** PASS : No User Access Administrator role assignments were found. **"
}