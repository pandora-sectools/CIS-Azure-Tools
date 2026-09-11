# 7.4 Ensure that Http Access from the Internet is Evaluated and Restricted (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$HttpReport = [System.Collections.Generic.List[Object]]::new()
$HttpPorts = @(80, 443)
$NSGs = az network nsg list -o json | ConvertFrom-Json

foreach ($NSG in $NSGs) {

    foreach ($Rule in $NSG.securityRules) {

        $Inbound = $Rule.direction -eq "Inbound"
        $Allow = $Rule.access -eq "Allow"
        $HttpOrAny = $Rule.protocol -in @("Tcp","*")

        $InternetSource =
            $Rule.sourceAddressPrefix -in @("*","0.0.0.0/0","Internet","Any") -or
            $Rule.sourceAddressPrefix -like "*/0"


        $HttpPort = $false

        foreach ($Port in $HttpPorts) {
            if (
                $Rule.destinationPortRange -eq "*" -or
                $Rule.destinationPortRange -eq "$Port" -or
                ($Rule.destinationPortRange -match "^(\d+)-(\d+)$" -and
                    [int]$Matches[1] -le $Port -and
                    [int]$Matches[2] -ge $Port)
            ) {
                $HttpPort = $true
            }
        }

        if ($Inbound -and $Allow -and $HttpOrAny -and $InternetSource -and $HttpPort) {

            $HttpReport.Add([PSCustomObject]@{
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

if (@($HttpReport).Count -gt 0) {
    Write-Host "** FAIL : NSG rules allow HTTP(s) access from the Internet. **"
    $HttpReport | Format-Table
}
else {
    Write-Host "** PASS : No NSG rules allow Sensitive HTTP(s) access from the Internet. **"
}
