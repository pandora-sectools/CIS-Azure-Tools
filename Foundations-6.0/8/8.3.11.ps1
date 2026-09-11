# 8.3.11 Ensure certificate 'Validity Period (in months)' is less than or equal to '12'
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output None
}

$CertificateReport = [System.Collections.Generic.List[Object]]::new()
$Vaults = az keyvault list -o json | ConvertFrom-Json

if (-not $Vaults) {
    Write-Host "** PASS : No Key Vaults found. **"
    return
}

foreach ($Vault in $Vaults) {

    Write-Host "." -NoNewline

    try {
        $CertificateJson = az keyvault certificate list `
            --vault-name $Vault.name `
            --query "[].{Name:name,Id:id,Enabled:attributes.enabled}" `
            -o json 2>$null

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to enumerate certificates."
        }

        $Certificates = $CertificateJson | ConvertFrom-Json

        foreach ($Certificate in @($Certificates)) {

            if ($Certificate.Enabled -eq $true) {

                try {
                    $Policy = Get-AzKeyVaultCertificatePolicy `
                        -VaultName $Vault.name `
                        -Name $Certificate.Name `
                        -ErrorAction Stop

                    $Obj = [PSCustomObject]@{
                        VaultName        = $Vault.name
                        CertificateName  = $Certificate.Name
                        ValidityInMonths = $Policy.ValidityInMonths
                        AuditState       = "PASS"
                    }

                    if ($Policy.ValidityInMonths -gt 12) {
                        $Obj.AuditState = "FAIL"
                    }

                    $CertificateReport.Add($Obj)
                }
                catch {
                    $CertificateReport.Add([PSCustomObject]@{
                        VaultName        = $Vault.name
                        CertificateName  = $Certificate.Name
                        ValidityInMonths = $null
                        AuditState       = "UNKNOWN"
                    })
                }
            }
        }
    }
    catch {
        $CertificateReport.Add([PSCustomObject]@{
            VaultName        = $Vault.name
            CertificateName  = $null
            ValidityInMonths = $null
            AuditState       = "UNKNOWN"
        })
    }
}

$FailingCertificates = $CertificateReport | Where-Object { $_.AuditState -eq "FAIL" }
$AccessIssues = $CertificateReport | Where-Object { $_.AuditState -eq "UNKNOWN" }

if (@($FailingCertificates).Count -gt 0) {
    Write-Host "`n** FAIL : Key Vault certificates found with a validity period greater than 12 months. **"
    $FailingCertificates | Format-Table VaultName, CertificateName, ValidityInMonths, AuditState -AutoSize
}
elseif (@($AccessIssues).Count -gt 0) {
    Write-Host "`n** PARTIAL : Unable to retrieve certificate policy for one or more Key Vault certificates. **"
    $AccessIssues | Format-Table VaultName, CertificateName, ValidityInMonths, AuditState -AutoSize
}
else {
    Write-Host "`n** PASS : All enabled Key Vault certificates have a validity period of 12 months or less. **"
    $CertificateReport | Format-Table VaultName, CertificateName, ValidityInMonths, AuditState -AutoSize
}
