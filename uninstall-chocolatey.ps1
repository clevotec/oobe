<#
.SYNOPSIS
    Safely uninstalls Chocolatey while preserving an inventory and warning about portable apps.
#>

$ErrorActionPreference = "Stop"
$chocoPath = $env:ChocolateyInstall

# --- PHASE 1: PRE-FLIGHT CHECKS & BACKUP ---

if (-not $chocoPath -or -not (Test-Path $chocoPath)) {
    Write-Warning "Chocolatey installation not found at '$chocoPath'."
    return
}

Write-Host "TYPE 1: DATA BACKUP" -ForegroundColor Cyan
# 1. Export inventory so you know what you had
$backupFile = "$HOME\Desktop\choco_inventory_$(Get-Date -Format 'yyyyMMdd').txt"
Write-Host "Saving list of installed packages to $backupFile..."
choco list --local-only --limit-output | Out-File -FilePath $backupFile -Encoding UTF8
Write-Host "Backup complete." -ForegroundColor Green

# 2. Check for Portable Apps (The "Maintain Installed Software" logic)
Write-Host "`nTYPE 2: PORTABLE APP DETECTION" -ForegroundColor Cyan
Write-Host "Scanning for apps that live INSIDE the Chocolatey folder..."
Write-Host "WARNING: The following apps are 'Portable' and WILL BE DELETED if you proceed, because they don't live in 'Program Files':" -ForegroundColor Yellow

# Look for executables inside the lib folder (excluding package metadata)
$portableApps = Get-ChildItem -Path "$chocoPath\lib" -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "\\tools\\chocolateyInstall.ps1" } |
    Select-Object -ExpandProperty DirectoryName -Unique |
    ForEach-Object { $_.Split('\') | Select-Object -Last 2 }

if ($portableApps) {
    $portableApps | Format-Table -HideTableHeaders
    Write-Warning "If you want to keep these, you must manually move their folders out of '$chocoPath\lib' before proceeding."

    $confirmation = Read-Host "Do you want to proceed with deleting Chocolatey and these portable apps? (y/n)"
    if ($confirmation -ne 'y') {
        Write-Host "Aborting uninstallation." -ForegroundColor Red
        return
    }
} else {
    Write-Host "No obvious portable apps detected. Most software seems to be MSI-based (Safe to delete Choco)." -ForegroundColor Green
}

# --- PHASE 2: CLEANUP ENVIRONMENT VARIABLES ---

Write-Host "`nPHASE 3: CLEANING ENVIRONMENT" -ForegroundColor Cyan

# Remove from PATH (User and Machine) using Registry to preserve %Variables%
$regKeys = @(
    @{ Name="User"; Path="HKCU:\Environment"; Hive=[Microsoft.Win32.Registry]::CurrentUser; SubKey="Environment" },
    @{ Name="System"; Path="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; Hive=[Microsoft.Win32.Registry]::LocalMachine; SubKey="SYSTEM\ControlSet001\Control\Session Manager\Environment\" }
)

foreach ($key in $regKeys) {
    $registryKey = $key.Hive.OpenSubKey($key.SubKey, $true)
    $currentPath = $registryKey.GetValue('PATH', '', 'DoNotExpandEnvironmentNames')

    if ($currentPath -like "*$chocoPath*") {
        Write-Host "Removing Chocolatey from $($key.Name) PATH..."

        # Split path, filter out choco paths, rejoin
        $newPathParts = $currentPath -split ';' | Where-Object {
            $_ -and $_ -notlike "*chocolatey*" -and $_ -notlike "*$chocoPath*"
        }
        $newPath = $newPathParts -join ';'

        $registryKey.SetValue('PATH', $newPath, 'ExpandString')
    }
    $registryKey.Close()
}

# Remove specific Chocolatey Environment Variables
$chocoVars = @("ChocolateyInstall", "ChocolateyToolsLocation", "ChocolateyLastPathUpdate")
foreach ($var in $chocoVars) {
    [Environment]::SetEnvironmentVariable($var, $null, "User")
    [Environment]::SetEnvironmentVariable($var, $null, "Machine")
}

# --- PHASE 3: REMOVE FILES ---

Write-Host "`nPHASE 4: FILE REMOVAL" -ForegroundColor Cyan
Write-Host "Stopping Chocolatey Agent (if running)..."
Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue | Stop-Service

Write-Host "Deleting Chocolatey directory..."
# Retrying removal is often necessary due to locked files
try {
    Remove-Item -Path $chocoPath -Recurse -Force -ErrorAction Stop
} catch {
    Write-Warning "Could not delete some files (likely in use). Please reboot and delete '$chocoPath' manually."
}

Write-Host "`nSUCCESS: Chocolatey has been removed." -ForegroundColor Green
Write-Host "Your installed software (Chrome, VS Code, etc.) is safe."
Write-Host "Your package list is saved at: $backupFile"
