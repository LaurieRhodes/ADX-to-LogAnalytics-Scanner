<#
.SYNOPSIS
    Deployment script for AAD-UserAndGroupExporttoADX Function App.

.DESCRIPTION
    Deploys Azure infrastructure using Bicep and uploads Function App code.
    Reads configuration from parameters.json with flat error handling.

.PARAMETER SkipInfrastructure
    Skip infrastructure deployment, only deploy code.

.PARAMETER ValidateOnly
    Only validate Bicep template without deploying.

.EXAMPLE
    .\deploy.ps1
    .\deploy.ps1 -SkipInfrastructure
    .\deploy.ps1 -ValidateOnly

.NOTES
    Author: Laurie Rhodes
    Version: 3.7 - Fixed Get-AzAccessToken breaking change warning
    Uses flat error handling - no nested try/catch blocks
#>

[CmdletBinding()]
param (
    [switch]$SkipInfrastructure
)

$ErrorActionPreference = "Stop"

# Get the script's directory to allow running from anywhere
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$configFile = Join-Path $scriptRoot "infrastructure\parameters.json"
$bicepTemplate = Join-Path $scriptRoot "infrastructure\main.bicep"
$sourceCode = Join-Path $scriptRoot "src\FunctionApp"

Write-Host "AAD Export Function App Deployment" -ForegroundColor Cyan

if (-not (Test-Path $configFile)) {
    Write-Error "Configuration file not found: $configFile"
    exit 1
}

$config = (Get-Content $configFile | ConvertFrom-Json).parameters
$resourceGroupName = ($config.resourceGroupID.value -split '/resourceGroups/')[1]
$functionAppName = $config.functionAppName.value
$subscriptionId = ($config.resourceGroupID.value -split '/')[2]

az account set --subscription $subscriptionId 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to set Azure subscription context"
    exit 1
}

if (-not $SkipInfrastructure) {
    Write-Host "Deploying infrastructure..." -ForegroundColor Blue
    
    $deployCmd = if ($ValidateOnly) { "validate" } else { "create" }
    
    az deployment group $deployCmd --resource-group $resourceGroupName --template-file $bicepTemplate --parameters $configFile --name "aadexport-$(Get-Date -Format 'yyyyMMdd-HHmmss')" 2>&1 | Where-Object { $_ -notmatch '^WARNING:' }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Infrastructure deployment failed"
        exit 1
    }
    
    Write-Host "Infrastructure operation completed" -ForegroundColor Green
}


    Write-Host "Deploying code..." -ForegroundColor Blue
    
    if (-not (Get-Module -ListAvailable Az.Websites)) {
        Write-Error "Az.Websites module required. Install with: Install-Module Az.Websites"
        exit 1
    }
    
    Import-Module Az.Websites
    
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Connect-AzAccount -Subscription $subscriptionId | Out-Null
    }
    
    $functionApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionAppName -ErrorAction SilentlyContinue
    if (-not $functionApp) {
        Write-Error "Function App $functionAppName not found"
        exit 1
    }
    
    $tempZip = "$env:TEMP\functionapp-$(Get-Date -Format 'HHmmss').zip"
    if (Test-Path $tempZip) {
        Remove-Item $tempZip -Force
    }
    
    Compress-Archive -Path "$sourceCode\*" -DestinationPath $tempZip -Force
    
    $publishProfile = Get-AzWebAppPublishingProfile -ResourceGroupName $resourceGroupName -Name $functionAppName
    $xmlProfile = [xml]$publishProfile
    $creds = $xmlProfile.SelectSingleNode("//publishProfile[@publishMethod='MSDeploy']")
    
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($creds.userName):$($creds.userPWD)"))
    $headers = @{ Authorization = "Basic $auth"; 'Content-Type' = "application/zip" }
    $deployUrl = "https://$functionAppName.scm.azurewebsites.net/api/zipdeploy"
    
    Invoke-RestMethod -Uri $deployUrl -Headers $headers -Method POST -InFile $tempZip -TimeoutSec 180
    
    Remove-Item $tempZip -Force
    
    $syncUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$functionAppName/syncfunctiontriggers?api-version=2024-11-01"
    
    # Get access token with -AsSecureString to avoid future breaking change
    $tokenResponse = Get-AzAccessToken -AsSecureString
    $secureToken = $tokenResponse.Token
    
    # Convert SecureString to plain text for the Authorization header
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    try {
        $token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
        $syncHeaders = @{ 'Authorization' = "Bearer $token" }
        
        $ErrorActionPreference = "SilentlyContinue"
        Invoke-RestMethod -Uri $syncUrl -Headers $syncHeaders -Method POST -TimeoutSec 30
        if ($Error[0]) {
            Write-Host "Trigger sync failed, restarting Function App..." -ForegroundColor Yellow
            Restart-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionAppName
        }
        $ErrorActionPreference = "Stop"
    }
    finally {
        # Always clear the token from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
    
    Write-Host "Code deployed" -ForegroundColor Green

Write-Host "Deployment completed!" -ForegroundColor Green
