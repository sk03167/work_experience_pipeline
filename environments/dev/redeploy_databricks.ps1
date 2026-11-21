<#
.SYNOPSIS
    Script to destroy expired Azure Databricks workspace and redeploy a fresh workspace.

.DESCRIPTION
    This script automates destroying the expired 14-day evaluation Databricks workspace
    and provisioning a new workspace (e.g., adb-ratecard-dev-002) using Terraform.
    It targets only the Databricks workspace resource, leaving ADLS Gen2 storage,
    Key Vault, and Azure Data Factory untouched.

.PARAMETER WorkspaceName
    The name of the new Databricks workspace (Default: 'adb-ratecard-dev-002').

.PARAMETER Sku
    The SKU for the new workspace: 'trial' (14-day free eval) or 'premium' (Default: 'trial').

.PARAMETER Mode
    'redeploy' (destroy expired & create new in one step)
    'destroy-only' (destroy the expired workspace only)
    'apply-only' (provision without forced replacement)
#>
param (
    [string]$WorkspaceName = "adb-ratecard-dev-002",
    [ValidateSet("trial", "premium")]
    [string]$Sku = "trial",
    [ValidateSet("redeploy", "destroy-only", "apply-only")]
    [string]$Mode = "redeploy"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Databricks Workspace Lifecycle Manager: Dev Environment" -ForegroundColor Cyan
Write-Host " Workspace Name : $WorkspaceName" -ForegroundColor Yellow
Write-Host " SKU            : $Sku" -ForegroundColor Yellow
Write-Host " Execution Mode : $Mode" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# Check if terraform is installed
if (-not (Get-Command "terraform" -ErrorAction SilentlyContinue)) {
    Write-Warning "Terraform is not found in your PATH."
    Write-Host "You can execute this via GitHub Actions workflow dispatch on branch 'main'/'dev':" -ForegroundColor Green
    Write-Host "  Repo -> Actions -> 'Terraform Infrastructure Apply' -> Run workflow" -ForegroundColor Green
    Write-Host "  Select Action: 'redeploy-databricks' or 'apply'" -ForegroundColor Green
    exit 0
}

Write-Host "`n[1/3] Initializing Terraform backend..." -ForegroundColor Cyan
terraform init

if ($Mode -eq "destroy-only") {
    Write-Host "`n[2/2] Destroying expired Databricks workspace ($WorkspaceName)..." -ForegroundColor Yellow
    terraform apply -destroy -target=module.databricks.azurerm_databricks_workspace.adb `
        -var="databricks_workspace_name=$WorkspaceName" `
        -var="databricks_sku=$Sku" `
        -auto-approve
    Write-Host "`nSuccessfully destroyed Databricks workspace." -ForegroundColor Green
}
elseif ($Mode -eq "redeploy") {
    Write-Host "`n[2/3] Replacing expired Databricks workspace..." -ForegroundColor Yellow
    terraform apply -replace=module.databricks.azurerm_databricks_workspace.adb `
        -var="databricks_workspace_name=$WorkspaceName" `
        -var="databricks_sku=$Sku" `
        -auto-approve
    Write-Host "`n[3/3] Successfully redeployed Databricks workspace ($WorkspaceName)!" -ForegroundColor Green
    
    $WorkspaceUrl = terraform output -raw databricks_workspace_url
    Write-Host "`nNew Databricks Workspace URL: https://$WorkspaceUrl" -ForegroundColor Cyan
}
else {
    Write-Host "`n[2/3] Applying Terraform configuration..." -ForegroundColor Yellow
    terraform apply `
        -var="databricks_workspace_name=$WorkspaceName" `
        -var="databricks_sku=$Sku" `
        -auto-approve
    Write-Host "`n[3/3] Successfully applied configuration!" -ForegroundColor Green
}
