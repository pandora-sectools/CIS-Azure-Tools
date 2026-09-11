# 8.3.2 Ensure that the Expiration Date is Set for all Keys in Key Vaults using Access Policies (Legacy) (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$KeyReport = [System.Collections.Generic.List[Object]]::new()

# Only evaluate Key Vaults using Access Policies (RBAC disabled)
$Vaults = az keyvault list `
    --query '[?properties.enableRbacAuthorization==`false`]' `
    -o json | ConvertFrom-Json

foreach ($Vault in $Vaults) {

    Write-Host "." -NoNewline

    try {
        $KeyJson = az keyvault key list `
            --vault-name $Vault.name `
            --query '[].{"kid":kid,"enabled":attributes.enabled,"expires":attributes.expires}' `
            -o json 2>&1

        if ($LASTEXITCODE -ne 0) { throw $KeyJson }

        $Keys = $KeyJson | ConvertFrom-Json

        foreach ($Key in $Keys) {

            if ($Key.enabled -eq $true) {

                $KeyReport.Add([PSCustomObject]@{
                    VaultName  = $Vault.name
                    KeyId      = $Key.kid
                    Enabled    = $Key.enabled
                    Expires    = $Key.expires
                    AuditState = if ($Key.expires) { "PASS" } else { "FAIL" }
                })
            }
        }
    }
    catch {

        $e = ([Regex]::Matches($_.Exception.Message, '{.*}').Value)

        $KeyReport.Add([PSCustomObject]@{
            VaultName  = $Vault.name
            KeyId      = $null
            Enabled    = $null
            Expires    = $null
            AuditState = if ($e) { $e } else { "UNKNOWN" }
        })
    }
}

$FailingKeys = $KeyReport | Where-Object { $_.AuditState -eq "FAIL" }
$AccessIssues = $KeyReport | Where-Object { $_.AuditState -notin @("PASS", "FAIL") }

if (@($FailingKeys).Count -gt 0) {
    Write-Host "`n** FAIL : Enabled Key Vault keys found without an expiration date in Key Vaults using Access Policies (Legacy). **"
    $FailingKeys | Format-Table
}
elseif (@($AccessIssues).Count -gt 0) {
    Write-Host "`n** PARTIAL : Access issue. Manual verification required. **"
    $AccessIssues | Format-Table
}
else {
    Write-Host "`n** PASS : All enabled Key Vault keys in Key Vaults using Access Policies (Legacy) have an expiration date set. **"
    $KeyReport | Format-Table
}
