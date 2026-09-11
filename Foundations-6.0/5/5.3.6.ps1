# 5.3.6 Ensure 'Tenant Creator' Role Assignments are Periodically Reviewed
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

# Query Microsoft Graph for Tenant Creator assignments
$AssignmentsJson = az rest `
    --method GET `
    --url "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$TenantCreatorRoleId'" `
    -o json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Tenant Creator role assignments. **"
    Write-Host $AssignmentsJson
    return
}

$TenantCreatorRoleId = "f2ef992c-3afb-46b9-b7cf-a126ee74c451"
$RoleReport = [System.Collections.Generic.List[Object]]::new()
$AssignmentsResponse = $AssignmentsJson | ConvertFrom-Json
$Assignments = @($AssignmentsResponse.value)

foreach ($Assignment in $Assignments) {

    Write-Host "." -NoNewline

    $Obj = [PSCustomObject]@{
        PrincipalName   = $null
        PrincipalType   = $null
        PrincipalId     = $Assignment.principalId
        DirectoryScope  = $Assignment.directoryScopeId
        AuditState      = "PARTIAL"
    }

    # Resolve the assigned principal
    $PrincipalJson = az rest `
        --method GET `
        --url "https://graph.microsoft.com/v1.0/directoryObjects/$($Assignment.principalId)" `
        -o json 2>&1

    if ($LASTEXITCODE -eq 0) {
        $Principal = $PrincipalJson | ConvertFrom-Json
        $Obj.PrincipalName = $Principal.displayName
        $Obj.PrincipalType = $Principal.'@odata.type' -replace '#microsoft.graph.', ''
    } else {
        $Obj.PrincipalName = $Assignment.principalId
        $Obj.PrincipalType = "Unknown"
    }

    $RoleReport.Add($Obj)

}

if (@($RoleReport).Count -gt 0) {
    Write-Host "`n** PARTIAL : Tenant Creator role assignments were found. Review and remove where not required. **"
    $RoleReport | Format-Table PrincipalName, PrincipalType, PrincipalId, DirectoryScope, AuditState -AutoSize
} else {
    Write-Host "** PASS : No Tenant Creator role assignments were found. **"
}