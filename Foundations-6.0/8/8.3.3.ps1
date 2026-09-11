# 8.3.3 Ensure that the Expiration Date is Set for all Secrets in RBAC Key Vaults (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SecretReport = [System.Collections.Generic.List[Object]]::new()

# Only evaluate Key Vaults using RBAC authorization
$Vaults = az keyvault list `
    --query "[?properties.enableRbacAuthorization==`true`]" `
    -o json | ConvertFrom-Json

foreach ($Vault in $Vaults) {

    Write-Host "." -NoNewline

    try {
        $SecretJson = az keyvault secret list `
            --vault-name $Vault.name `
            --query '[].{"id":id,"enabled":attributes.enabled,"expires":attributes.expires}' `
            -o json 2>&1

        if ($LASTEXITCODE -ne 0) { throw $SecretJson }

        $Secrets = $SecretJson | ConvertFrom-Json

        foreach ($Secret in $Secrets) {
            if ($Secret.enabled -eq $true) {
                $SecretReport.Add([PSCustomObject]@{
                    VaultName  = $Vault.name
                    SecretId   = $Secret.id
                    Enabled    = $Secret.enabled
                    Expires    = $Secret.expires
                    AuditState = if ($Secret.expires) { "PASS" } else { "FAIL" }
                })
            }
        }
    }
    catch {

        $e = ([Regex]::Matches($_.Exception.Message, '{.*}').Value)

        $SecretReport.Add([PSCustomObject]@{
            VaultName  = $Vault.name
            SecretId   = $null
            Enabled    = $null
            Expires    = $null
            AuditState = if ($e) { $e } else { "UNKNOWN" }
        })
    }
}

$FailingSecrets = $SecretReport | Where-Object { $_.AuditState -eq "FAIL" }
$AccessIssues = $SecretReport | Where-Object { $_.AuditState -notin @("PASS", "FAIL") }

if (@($FailingSecrets).Count -gt 0) {
    Write-Host "`n** FAIL : Enabled Key Vault secrets found without an expiration date in RBAC Key Vaults. **"
    $FailingSecrets | Format-Table
}
elseif (@($AccessIssues).Count -gt 0) {
    Write-Host "`n** PARTIAL : Access issue. Manual verification required. **"
    $AccessIssues | Format-Table
}
else {
    Write-Host "`n** PASS : All enabled Key Vault secrets in RBAC Key Vaults have an expiration date set. **"
    $SecretReport | Format-Table
}
