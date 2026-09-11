# 5.3.7 Ensure All Non-privileged Role Assignments are Periodically Reviewed
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

# Get all Entra role definitions
$RoleDefinitionsJson = az rest `
    --method GET `
    --url "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions" `
    -o json 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Entra role definitions. **"
    return
}

$RoleReport = [System.Collections.Generic.List[Object]]::new()
$RoleDefinitionsResponse = $RoleDefinitionsJson | ConvertFrom-Json
$RoleDefinitions = @($RoleDefinitionsResponse.value)

# Get all active Entra role assignments
$AssignmentsJson = az rest `
    --method GET `
    --url "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments" `
    -o json 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "** ERROR : Unable to enumerate Entra role assignments. **"
    Write-Host $AssignmentsJson
    return
}

$AssignmentsResponse = $AssignmentsJson | ConvertFrom-Json
$Assignments = @($AssignmentsResponse.value)

foreach ($Assignment in $Assignments) {
    
    Write-Host "." -NoNewline

    $RoleDefinition = $RoleDefinitions | Where-Object {
        $_.id -eq $Assignment.roleDefinitionId
    }

    # Skip privileged roles - covered by 5.3.4
    if ($RoleDefinition.isPrivileged -eq $true) {
        continue
    }

    $Obj = [PSCustomObject]@{
        PrincipalName  = $null
        PrincipalType  = $null
        RoleName       = $RoleDefinition.displayName
        PrincipalId    = $Assignment.principalId
        DirectoryScope = $Assignment.directoryScopeId
        AuditState     = "PARTIAL"
    }

    # Resolve assigned principal
    $PrincipalJson = az rest `
        --method GET `
        --url "https://graph.microsoft.com/v1.0/directoryObjects/$($Assignment.principalId)" `
        -o json 2>&1

    if ($LASTEXITCODE -eq 0) {
        $Principal = $PrincipalJson | ConvertFrom-Json
        $Obj.PrincipalName = $Principal.displayName
        $Obj.PrincipalType = $Principal.'@odata.type' -replace '#microsoft.graph.', ''
    }
    else {
        $Obj.PrincipalName = $Assignment.principalId
        $Obj.PrincipalType = "Unknown"
    }

    $RoleReport.Add($Obj)
}

if (@($RoleReport).Count -gt 0) {
    Write-Host "`n** PARTIAL : Non-privileged role assignments were found. Review and remove where not required. **"
    $RoleReport | Format-Table PrincipalName, PrincipalType, RoleName, DirectoryScope, AuditState -AutoSize
} else {
    Write-Host "** PASS : No non-privileged role assignments were found. **"
}
