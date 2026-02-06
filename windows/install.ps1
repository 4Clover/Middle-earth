# Middle-earth WSL Configuration Installer
# Automatically detects hostname and applies the correct .wslconfig

$ErrorActionPreference = "Stop"

# Detect hostname
$hostname = $env:COMPUTERNAME.ToLower()
Write-Host "Detected hostname: $hostname"

# Map hostname to config file
$configFile = ""
if ($hostname -like "*aragorn*") {
    $configFile = "aragorn.wslconfig"
} elseif ($hostname -like "*legolas*") {
    $configFile = "legolas.wslconfig"
} else {
    Write-Host "Unknown hostname. Available configs:" -ForegroundColor Yellow
    Write-Host "  - aragorn.wslconfig (Desktop: 32GB RAM, 16-core CPU)"
    Write-Host "  - legolas.wslconfig (Laptop: 16GB RAM, 8-core CPU)"
    $configFile = Read-Host "Enter config filename to use"
}

$sourcePath = Join-Path $PSScriptRoot $configFile
$targetPath = Join-Path $env:USERPROFILE ".wslconfig"

# Check if source exists
if (-not (Test-Path $sourcePath)) {
    Write-Error "Config file not found: $sourcePath"
    exit 1
}

# Warn if target exists
if (Test-Path $targetPath) {
    Write-Warning "Existing .wslconfig will be overwritten at: $targetPath"
    $confirm = Read-Host "Continue? (y/N)"
    if ($confirm -ne "y") {
        Write-Host "Cancelled."
        exit 0
    }
}

# Copy file
Copy-Item $sourcePath $targetPath -Force
Write-Host "✓ Copied $configFile to $targetPath" -ForegroundColor Green

# Remind about restart
Write-Host ""
Write-Host "IMPORTANT: Run 'wsl --shutdown' for changes to take effect." -ForegroundColor Cyan
Write-Host "Then restart your WSL distribution: wsl -d NixOS"
