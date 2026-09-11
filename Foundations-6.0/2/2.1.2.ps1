# 2.1.2 Ensure that Network Security Groups are Configured for Databricks Subnets (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

$Workspaces = az resource list `
    --resource-type "Microsoft.Databricks/workspaces" `
    --query "[].{Name:name,ResourceGroup:resourceGroup,Id:id}" `
    -o json | ConvertFrom-Json

if (-not $Workspaces) {
    Write-Host "** NOT APPLICABLE : No Azure Databricks workspaces found in this subscription. **"
    return
}

$NSGReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Workspace in $Workspaces) {

    $WorkspaceInfo = az resource show `
        --resource-group $Workspace.ResourceGroup `
        --name $Workspace.Name `
        --resource-type "Microsoft.Databricks/workspaces" `
        -o json | ConvertFrom-Json

    $VirtualNetworkId = $WorkspaceInfo.properties.parameters.customVirtualNetworkId.value

    if ([string]::IsNullOrWhiteSpace($VirtualNetworkId)) {
        $NSGReport.Add([PSCustomObject]@{
            Workspace        = $Workspace.Name
            ResourceGroup    = $Workspace.ResourceGroup
            VNetName         = ""
            SubnetName       = ""
            NSGName          = ""
            NSGId            = ""
            AuditState       = "NOT APPLICABLE"
            Reason           = "Workspace is not deployed in a customer-managed VNet"
        })
        continue
    }

    $VNetResourceGroup = ($VirtualNetworkId -split "/")[4]
    $VNetName = ($VirtualNetworkId -split "/")[-1]

    $VNetInfo = az network vnet show `
        --resource-group "$VNetResourceGroup" `
        --name "$VNetName" `
        -o json | ConvertFrom-Json

    $DatabricksSubnets = $VNetInfo.subnets | Where-Object {
        $_.delegations.serviceName -contains "Microsoft.Databricks/workspaces" -or
        $_.name -match "databricks|adb|dbx"
    }

    if (-not $DatabricksSubnets) {
        $NSGReport.Add([PSCustomObject]@{
            Workspace        = $Workspace.Name
            ResourceGroup    = $Workspace.ResourceGroup
            VNetName         = $VNetName
            SubnetName       = ""
            NSGName          = ""
            NSGId            = ""
            AuditState       = "FAIL"
            Reason           = "No Databricks subnets found in customer-managed VNet"
        })
        continue
    }

    foreach ($Subnet in $DatabricksSubnets) {
        $NSGId = $Subnet.networkSecurityGroup.id

        $NSGReport.Add([PSCustomObject]@{
            Workspace        = $Workspace.Name
            ResourceGroup    = $Workspace.ResourceGroup
            VNetName         = $VNetName
            SubnetName       = $Subnet.name
            NSGName          = if ($NSGId) { ($NSGId -split "/")[-1] } else { "" }
            NSGId            = if ($NSGId) { $NSGId } else { "" }
            AuditState       = if ($NSGId) { "PASS" } else { "FAIL" }
            Reason           = if ($NSGId) { "NSG attached to Databricks subnet" } else { "No NSG attached to Databricks subnet" }
        })
    }
}

$FailingSubnets = $NSGReport | Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingSubnets).Count -gt 0) {
    Write-Host "** FAIL : Databricks subnets are missing NSGs. **"
    $FailingSubnets | Format-List
} else {
    Write-Host "** PASS : Databricks subnets have NSGs attached. **"
    $NSGReport | Format-List
}