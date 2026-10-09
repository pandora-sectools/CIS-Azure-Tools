# 5.3.5 Ensure Disabled User Accounts do not Have Read, Write, or Owner Permissions (Manual)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

# Fetch enabled subscriptions
$Subscriptions = @(
    az account list --all --refresh `
        --query "[?state=='Enabled'].{Name:name,Id:id,TenantId:tenantId}" `
        -o json | ConvertFrom-Json
)

$RoleReport = [System.Collections.Generic.List[Object]]::new()
$Errors = [System.Collections.Generic.List[Object]]::new()

foreach ($Subscription in $Subscriptions) {

    Write-Host "`nSelecting Subscription: $($Subscription.Name)"
    az account set --subscription $Subscription.Id 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        "** ERROR : Cannot retrieve disabled users for $($Subscription.Name) **"
        continue
    }

    # Get disabled users in the subscription's tenant
    $DisabledUsers = @(
        az ad user list `
            --filter "accountEnabled eq false" `
            --query "[].{DisplayName:displayName,UPN:userPrincipalName,ObjectId:id}" `
            -o json | ConvertFrom-Json
    )

    if ($LASTEXITCODE -ne 0) {
        "** ERROR : Cannot retrieve disabled users for $($Subscription.Name) **"
        continue
    }

    foreach ($User in $DisabledUsers) {

        Write-Host "." -NoNewline

        $RoleAssignments = @(
            az role assignment list `
                --subscription $Subscription.Id `
                --assignee-object-id $User.ObjectId `
                --all `
                --fill-principal-name false `
                --query "[?contains(roleDefinitionName, 'Reader') || contains(roleDefinitionName, 'Contributor') || contains(roleDefinitionName, 'Owner')].{Role:roleDefinitionName,Scope:scope}" `
                -o json | ConvertFrom-Json
        )

        if ($LASTEXITCODE -ne 0) {
            $Errors += "RBAC query failed: $($User.UPN) - $($Subscription.Name)"
            continue
        }

        foreach ($Role in $RoleAssignments) {
            $RoleReport += [PSCustomObject]@{
                Subscription = $Subscription.Name
                TenantId     = $Subscription.TenantId
                DisplayName  = $User.DisplayName
                UPN          = $User.UPN
                ObjectId     = $User.ObjectId
                Role         = $Role.Role
                Scope        = $Role.Scope
            }
        }
    }
}

# Results
if ($RoleReport.Count -gt 0) {
    Write-Host "`n** FAIL : Disabled user accounts have read, write, or owner permissions. **"
    $RoleReport | Format-List
}
elseif ($Errors.Count -gt 0) {
    Write-Host "`n** INCOMPLETE : Some checks failed. **"
}
else {
    Write-Host "`n** PASS : No matching direct permissions found. **"
}

$Errors | ForEach-Object { Write-Warning $_ }
