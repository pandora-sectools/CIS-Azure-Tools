# 7.3 Ensure that UDP Access from the Internet is Evaluated and Restricted (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$UdpReport = [System.Collections.Generic.List[Object]]::new()
$UdpPorts = @(53, 123, 161, 389, 1900)
$NSGs = az network nsg list -o json | ConvertFrom-Json

foreach ($NSG in $NSGs) {

    foreach ($Rule in $NSG.securityRules) {

        $Inbound = $Rule.direction -eq "Inbound"
        $Allow = $Rule.access -eq "Allow"
        $UdpOrAny = $Rule.protocol -in @("Udp","*")

        $InternetSource =
            $Rule.sourceAddressPrefix -in @("*","0.0.0.0/0","Internet","Any") -or
            $Rule.sourceAddressPrefix -like "*/0"


        $UdpPort = $false

        foreach ($Port in $UdpPorts) {
            if (
                $Rule.destinationPortRange -eq "*" -or
                $Rule.destinationPortRange -eq "$Port" -or
                ($Rule.destinationPortRange -match "^(\d+)-(\d+)$" -and
                    [int]$Matches[1] -le $Port -and
                    [int]$Matches[2] -ge $Port)
            ) {
                $UdpPort = $true
            }
        }

        if ($Inbound -and $Allow -and $UdpOrAny -and $InternetSource -and $UdpPort) {

            $UdpReport.Add([PSCustomObject]@{
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

if (@($UdpReport).Count -gt 0) {
    Write-Host "** FAIL : NSG rules allow Sensitive UDP access from the Internet. **"
    $UdpReport | Format-Table
}
else {
    Write-Host "** PASS : No NSG rules allow Sensitive UDP access from the Internet. **"
}