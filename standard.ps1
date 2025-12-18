#Requires -RunAsAdministrator

<#
.SYNOPSIS
    OOBE Setup Script - Standard Edition
.DESCRIPTION
    Modernized OOBE setup script using winget for package management.
    Configures Windows and installs standard office and creative applications.
.NOTES
    For interactive setup with package selection, use setup.ps1 instead.
#>

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load modules
. "$ScriptPath\common.ps1"
. "$ScriptPath\packages.ps1"

Write-Host "=== Standard OOBE Setup Script ===" -ForegroundColor Cyan
Write-Host "Modernized with winget package management" -ForegroundColor Green
Write-Host ""

# Chocolatey Migration
Invoke-ChocolateyMigration

# Verify Winget
if (-not (Test-WingetAvailable)) {
    Write-Error "Cannot proceed without winget. Exiting."
    exit 1
}

# Windows Configuration
Set-CommonWindowsSettings
Set-FileExplorerSettings -ShowFileExtensions $true -ShowHiddenFiles $false

# Package Installation
Write-Host "`n=== Installing Packages ===" -ForegroundColor Cyan

$packages = Get-PackagesForProfile -Profile "Standard"
foreach ($pkg in $packages) {
    $source = if ($pkg.Source) { $pkg.Source } else { "winget" }
    Install-WingetPackage -PackageId $pkg.Id -Name $pkg.Name -Source $source
}

Write-Host "`n  [OK] Package installation complete" -ForegroundColor Green

# OneDrive Configuration
Set-OneDriveForBusiness -TenantGUID '3db75043-219a-4c39-90e2-88cd1838fca4'

# Windows Hello
Enable-WindowsHelloForBusiness

# Post-Installation Configuration
Write-Host "`n=== Post-Installation Configuration ===" -ForegroundColor Cyan

Set-NotepadPlusPlusAsDefault
Set-KeePassXCBrowserExtensions -Chrome $true -Edge $true -Brave $true
Remove-PersonalTeamsApp
Register-WingetAutoUpdate

# Windows Updates
Install-WindowsUpdates

Write-Host "`n=== OOBE Setup Complete! ===" -ForegroundColor Green
Write-Host "A restart may be required to complete installation of some features." -ForegroundColor Yellow
Write-Host ""
