# 2.1.1 Ensure that Azure Databricks is deployed in a customer-managed virtual network (VNet) (Automated)
# Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

$Workspaces = az resource list `
    --resource-type "Microsoft.Databricks/workspaces" `
    --query "[].{Id:id,Name:name,ResourceGroup:resourceGroup}" `
    -o json | ConvertFrom-Json

if (-not $Workspaces) {
    Write-Host "** NOT APPLICABLE : No Azure Databricks workspaces found in this subscription. **"
    return
}


$VNetReport = [System.Collections.Generic.List[Object]]::new()
foreach ($Workspace in $Workspaces) {

    $WorkspaceInfo = az resource show `
        --resource-group $Workspace.ResourceGroup `
        --name $Workspace.Name `
        --resource-type "Microsoft.Databricks/workspaces" `
        -o json | ConvertFrom-Json

    $VirtualNetworkId = $WorkspaceInfo.properties.parameters.customVirtualNetworkId.value

    $VNetReport.Add([PSCustomObject]@{
        id               = $Workspace.Id
        Workspace        = $Workspace.Name
        ResourceGroup    = $Workspace.ResourceGroup
        VirtualNetworkId = $VirtualNetworkId
        AuditState       = if ([string]::IsNullOrWhiteSpace($VirtualNetworkId)) { "FAIL" } else { "PASS" }
    })
}

$FailingWorkspaces = $VNetReport | Where-Object { $_.AuditState -eq "FAIL" }
if (@($FailingWorkspaces).Count -gt 0) {
    Write-Host "** FAIL : Databricks workspaces are not deployed in a customer-managed VNet. **"
    $FailingWorkspaces | Format-List
} else {
    Write-Host "** PASS : Databricks workspaces are deployed in a customer-managed VNet. **"
    $VNetReport | Format-List
}
