# 7.2 Ensure that SSH Access from the Internet is Evaluated and Restricted (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SshReport = [System.Collections.Generic.List[Object]]::new()

$NSGs = az network nsg list -o json | ConvertFrom-Json

foreach ($NSG in $NSGs) {

    foreach ($Rule in $NSG.securityRules) {

        $Inbound = $Rule.direction -eq "Inbound"
        $Allow = $Rule.access -eq "Allow"
        $TcpOrAny = $Rule.protocol -in @("Tcp","*")

        $InternetSource =
            $Rule.sourceAddressPrefix -in @("*","0.0.0.0/0","Internet","Any") -or
            $Rule.sourceAddressPrefix -like "*/0"

        $SshPort =
            $Rule.destinationPortRange -eq "22" -or
            ($Rule.destinationPortRange -match "^(\d+)-(\d+)$" -and
                [int]$Matches[1] -le 22 -and
                [int]$Matches[2] -ge 22)

        if ($Inbound -and $Allow -and $TcpOrAny -and $InternetSource -and $SshPort) {

            $SshReport.Add([PSCustomObject]@{
                NSGName      = $NSG.name
                RuleName     = $Rule.name
                Source       = $Rule.sourceAddressPrefix
                Destination  = $Rule.destinationPortRange
                Protocol     = $Rule.protocol
                AuditState   = "FAIL"
            })
        }
    }
}

if (@($SshReport).Count -gt 0) {
    Write-Host "** FAIL : NSG rules allow SSH (22) access from the Internet. **"
    $SshReport | Format-Table
}
else {
    Write-Host "** PASS : No NSG rules allow SSH (22) access from the Internet. **"
}