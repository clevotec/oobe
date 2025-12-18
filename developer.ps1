#Requires -RunAsAdministrator

<#
.SYNOPSIS
    OOBE Setup Script - Developer Edition
.DESCRIPTION
    Modernized OOBE setup script using winget for package management.
    Configures Windows and installs developer tools and applications.
.NOTES
    For interactive setup with package selection, use setup.ps1 instead.
#>

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load modules
. "$ScriptPath\common.ps1"
. "$ScriptPath\packages.ps1"

Write-Host "=== Developer OOBE Setup Script ===" -ForegroundColor Cyan
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
Set-FileExplorerSettings -ShowFileExtensions $true -ShowHiddenFiles $true
Enable-RemoteDesktop

# Package Installation
Write-Host "`n=== Installing Packages ===" -ForegroundColor Cyan

$packages = Get-PackagesForProfile -Profile "Developer"
foreach ($pkg in $packages) {
    $source = if ($pkg.Source) { $pkg.Source } else { "winget" }
    Install-WingetPackage -PackageId $pkg.Id -Name $pkg.Name -Source $source
}

Write-Host "`n  [OK] Package installation complete" -ForegroundColor Green

# Windows Features
Write-Host "`n=== Installing Windows Features ===" -ForegroundColor Cyan

Install-WindowsFeature -FeatureName "Microsoft-Hyper-V-All" -DisplayName "Hyper-V"
Install-WindowsFeature -FeatureName "Containers-DisposableClientVM" -DisplayName "Windows Sandbox"
Install-WSL

# Windows Hello
Enable-WindowsHelloForBusiness

# Post-Installation Configuration
Write-Host "`n=== Post-Installation Configuration ===" -ForegroundColor Cyan

# Pin Firefox to Taskbar (manual step required)
$firefoxPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    Write-Host "  (i) Please pin Firefox to taskbar manually" -ForegroundColor Gray
}

Set-NotepadPlusPlusAsDefault
Set-KeePassXCBrowserExtensions -Chrome $true -Edge $true -Brave $true
Remove-PersonalTeamsApp
Register-WingetAutoUpdate

# Windows Updates
Install-WindowsUpdates

Write-Host "`n=== OOBE Setup Complete! ===" -ForegroundColor Green
Write-Host "A restart may be required to complete installation of some features." -ForegroundColor Yellow
Write-Host ""
