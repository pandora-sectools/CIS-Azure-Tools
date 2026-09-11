# 7.1 Ensure that RDP Access from the Internet is Evaluated and Restricted (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$RdpReport = [System.Collections.Generic.List[Object]]::new()

$NSGs = az network nsg list -o json | ConvertFrom-Json

foreach ($NSG in $NSGs) {

    foreach ($Rule in $NSG.securityRules) {

        $Inbound = $Rule.direction -eq "Inbound"
        $Allow = $Rule.access -eq "Allow"
        $TcpOrAny = $Rule.protocol -in @("Tcp","*")

        $InternetSource =
            $Rule.sourceAddressPrefix -in @("*","0.0.0.0/0","Internet","Any") -or
            $Rule.sourceAddressPrefix -like "*/0"

        $RdpPort =
            $Rule.destinationPortRange -eq "3389" -or
            ($Rule.destinationPortRange -match "^(\d+)-(\d+)$" -and
                [int]$Matches[1] -le 3389 -and
                [int]$Matches[2] -ge 3389)

        if ($Inbound -and $Allow -and $TcpOrAny -and $InternetSource -and $RdpPort) {

            $RdpReport.Add([PSCustomObject]@{
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


if (@($RdpReport).Count -gt 0) {
    Write-Host "** FAIL : NSG rules allow RDP (3389) access from the Internet. **"
    $RdpReport | Format-Table
}
else {
    Write-Host "** PASS : No NSG rules allow RDP (3389) access from the Internet. **"
}