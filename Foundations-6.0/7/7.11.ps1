# 7.11 Ensure Subnets Are Associated with Network Security Groups (Automated)
# Level 1

if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az login --allow-no-subscriptions --output none
}

$SubnetReport = [System.Collections.Generic.List[Object]]::new()
$ResourceGroups = az group list -o json | ConvertFrom-Json

foreach ($RG in $ResourceGroups) {

    $VNets = az network vnet list --resource-group $RG.name -o json | ConvertFrom-Json

    foreach ($VNet in $VNets) {

        Write-Host "." -NoNewline

        foreach ($Subnet in $VNet.subnets) {

            $SubnetReport.Add([PSCustomObject]@{
                VNetName             = $VNet.name
                ResourceGroup        = $VNet.resourceGroup
                SubnetName           = $Subnet.name
                NetworkSecurityGroup = $Subnet.networkSecurityGroup.id
                AuditState           = if ($Subnet.networkSecurityGroup.id) { "PASS" } else { "FAIL" }
            })
        }
    }
}

$FailingSubnets = $SubnetReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingSubnets).Count -gt 0) {
    Write-Host "`n** FAIL : Subnets found without Network Security Groups associated. **"
    $FailingSubnets | Format-Table
}
else {
    Write-Host "`n** PASS : All subnets are associated with Network Security Groups. **"
}