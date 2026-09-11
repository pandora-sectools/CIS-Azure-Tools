# 8.3.5 Ensure that the Expiration Date is Set for all Certificates in RBAC Key Vaults (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$CertificateReport = [System.Collections.Generic.List[Object]]::new()

# Only evaluate Key Vaults using RBAC authorization
$Vaults = az keyvault list `
    --query '[?properties.enableRbacAuthorization==`true`]' `
    -o json | ConvertFrom-Json

foreach ($Vault in $Vaults) {

    Write-Host "." -NoNewline

    try {
        $CertificateJson = az keyvault certificate list `
            --vault-name $Vault.name `
            --query '[].{"id":id,"enabled":attributes.enabled,"expires":attributes.expires}' `
            -o json 2>&1

        if ($LASTEXITCODE -ne 0) { throw $CertificateJson }

        $Certificates = $CertificateJson | ConvertFrom-Json

        foreach ($Certificate in $Certificates) {
            if ($Certificate.enabled -eq $true) {
                $CertificateReport.Add([PSCustomObject]@{
                    VaultName     = $Vault.name
                    CertificateId = $Certificate.id
                    Enabled       = $Certificate.enabled
                    Expires       = $Certificate.expires
                    AuditState    = if ($Certificate.expires) { "PASS" } else { "FAIL" }
                })
            }
        }
    }
    catch {

        $e = ([Regex]::Matches($_.Exception.Message, '{.*}').Value)

        $CertificateReport.Add([PSCustomObject]@{
            VaultName     = $Vault.name
            CertificateId = $null
            Enabled       = $null
            Expires       = $null
            AuditState    = if ($e) { $e } else { "UNKNOWN" }
        })
    }
}

$FailingCertificates = $CertificateReport | Where-Object { $_.AuditState -eq "FAIL" }
$AccessIssues = $CertificateReport | Where-Object { $_.AuditState -notin @("PASS", "FAIL") }

if (@($FailingCertificates).Count -gt 0) {
    Write-Host "`n** FAIL : Enabled Key Vault certificates found without an expiration date in RBAC Key Vaults. **"
    $FailingCertificates | Format-Table
}
elseif (@($AccessIssues).Count -gt 0) {
    Write-Host "`n** PARTIAL : Access issue. Manual verification required. **"
    $AccessIssues | Format-Table
}
else {
    Write-Host "`n** PASS : All enabled Key Vault certificates in RBAC Key Vaults have an expiration date set. **"
    $CertificateReport | Format-Table
}
