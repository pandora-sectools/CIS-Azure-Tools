# 5.3.5 Ensure Disabled User Accounts do not Have Read, Write, or Owner Permissions (Manual)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

$DisabledUsers = az ad user list `
    --filter "accountEnabled eq false" `
    --query "[].{DisplayName:displayName,UPN:userPrincipalName,ObjectId:id}" `
    -o json | ConvertFrom-Json

if (-not $DisabledUsers) {
    Write-Host "** PASS : No disabled user accounts found. **"
    return
}

$RoleReport = [System.Collections.Generic.List[Object]]::new()

foreach ($User in $DisabledUsers) {

    Write-Host "." -NoNewline

    $RoleAssignments = az role assignment list `
        --assignee-object-id "$($User.ObjectId)" `
        --all `
        --fill-principal-name false `
        --query "[?contains(roleDefinitionName, 'Reader') || contains(roleDefinitionName, 'Contributor') || contains(roleDefinitionName, 'Owner')].{Role:roleDefinitionName,Scope:scope}" `
        -o json | ConvertFrom-Json

    foreach ($Role in $RoleAssignments) {
        $RoleReport.Add([PSCustomObject]@{
            DisplayName = $User.DisplayName
            UPN         = $User.UPN
            ObjectId    = $User.ObjectId
            Role        = $Role.Role
            Scope       = $Role.Scope
        })
    }
}

if (@($RoleReport).Count -gt 0) {
    Write-Host "`n** PARTIAL : Disabled user accounts have read, write, or owner permissions. Review and remove where not required. **"
    $RoleReport | Format-List
} else {
    Write-Host "** PASS : Disabled user accounts do not have read, write, or owner permissions. **"
}