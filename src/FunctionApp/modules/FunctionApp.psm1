# Get public and private function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
ForEach ($import in @($Public + $Private)) {
    Try {
        # Use the same lightweight alternative as the legacy app
        . ([ScriptBlock]::Create([System.Io.File]::ReadAllText($import)))
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export only the public functions
Export-ModuleMember -Function $Public.Basename
