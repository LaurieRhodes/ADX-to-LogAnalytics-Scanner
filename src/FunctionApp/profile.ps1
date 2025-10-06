# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper methods, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI (comments show best practices)
# Disable-AzContextAutosave -Scope Process | Out-Null
# Connect-AzAccount -Identity

# Enhanced module loading with proper error handling and dynamic discovery
Write-Information "Function App Cold Start - Loading PowerShell modules"

try {
    # Load all modules from the modules directory
    $moduleDirectory = Join-Path $PSScriptRoot "modules"
    
    if (Test-Path $moduleDirectory) {
        # Get all PowerShell module files
        $moduleFiles = Get-ChildItem -Path $moduleDirectory -Recurse -Filter "*.psm1"
        
        Write-Information "Found $($moduleFiles.Count) module files to load"
        
        foreach ($moduleFile in $moduleFiles) {
            try {
                Write-Information "Loading module: $($moduleFile.Name)"
                Import-Module $moduleFile.FullName -Force -Global
                Write-Information "✓ Successfully loaded: $($moduleFile.Name)"
            }
            catch {
                Write-Warning "❌ Failed to load module $($moduleFile.Name): $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warning "Module directory not found: $moduleDirectory"
    }
    
    Write-Information "✓ Module loading completed"
}
catch {
    Write-Error "💥 Critical error during module loading: $($_.Exception.Message)"
}

Write-Information "🚀 Function App initialization completed - Ready for requests"
