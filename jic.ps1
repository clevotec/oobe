#Requires -RunAsAdministrator

<#
.SYNOPSIS
    OOBE Setup Script - JIC (Business/Office Edition)
.DESCRIPTION
    Modernized OOBE setup script using winget for package management.
    Configures Windows and installs business productivity applications.
#>

Write-Host "=== JIC OOBE Setup Script ===" -ForegroundColor Cyan
Write-Host "Modernized with winget package management" -ForegroundColor Green
Write-Host ""

#region Helper Functions

function Install-WingetPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageId,
        [string]$Name = $PackageId,
        [string]$Source = "winget"
    )

    Write-Host "Installing $Name..." -ForegroundColor Yellow
    try {
        winget install --id $PackageId --source $Source --silent --accept-package-agreements --accept-source-agreements
        Write-Host "  ✓ $Name installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Warning "  ✗ Failed to install $Name : $_"
    }
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWORD"
    )

    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

#endregion

#region Windows Configuration

Write-Host "`n=== Configuring Windows Settings ===" -ForegroundColor Cyan

# Disable Bing Search in Start Menu
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0

# Disable Game Bar Tips
Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Value 0

# Hide File Extensions (Business preference)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1

# Hide Hidden Files and Folders (Business preference)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 2

# Disable Search Box on Taskbar (use icon only)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1

Write-Host "  ✓ Windows configuration complete" -ForegroundColor Green

#endregion

#region Winget Setup

Write-Host "`n=== Verifying Winget Installation ===" -ForegroundColor Cyan

# Check if winget is available
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed. Please install App Installer from the Microsoft Store or ensure you're running Windows 10 1809+ or Windows 11."
    exit 1
}

Write-Host "  ✓ Winget is available" -ForegroundColor Green

# Update winget sources
Write-Host "Updating winget sources..." -ForegroundColor Yellow
winget source update

#endregion

#region Package Installation

Write-Host "`n=== Installing Packages ===" -ForegroundColor Cyan

# Utilities
Install-WingetPackage -PackageId "7zip.7zip" -Name "7-Zip"

# Browsers
Install-WingetPackage -PackageId "Brave.Brave" -Name "Brave Browser"
Install-WingetPackage -PackageId "Microsoft.Edge" -Name "Microsoft Edge"

# Communication
Install-WingetPackage -PackageId "Microsoft.Teams" -Name "Microsoft Teams"
Install-WingetPackage -PackageId "Zoom.Zoom" -Name "Zoom"

# Office & Productivity
Install-WingetPackage -PackageId "Microsoft.Office" -Name "Microsoft Office"
Install-WingetPackage -PackageId "Adobe.Acrobat.Reader.64-bit" -Name "Adobe Acrobat Reader"
Install-WingetPackage -PackageId "Foxit.FoxitReader" -Name "Foxit PDF Reader"

# Security
Install-WingetPackage -PackageId "DominikReichl.KeePass" -Name "KeePass"

# Media
Install-WingetPackage -PackageId "VideoLAN.VLC" -Name "VLC Media Player"

Write-Host "`n  ✓ Package installation complete" -ForegroundColor Green

# Note: KeePass plugins (keepass-rpc) need to be installed manually
Write-Host "`nNote: KeePass plugins need to be installed manually:" -ForegroundColor Yellow
Write-Host "  - KeePassRPC: https://github.com/kee-org/keepassrpc/releases" -ForegroundColor Gray

#endregion

#region OneDrive Configuration

Write-Host "`n=== Configuring OneDrive for Business ===" -ForegroundColor Cyan

$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'
$TenantGUID = 'd911a68a-30cf-4719-80e6-dab4d56bfc93'

if (!(Test-Path $HKLMregistryPath)) {
    New-Item -Path $HKLMregistryPath -Force | Out-Null
}

Set-RegistryValue -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value 1 -Type "DWORD"
Set-RegistryValue -Path $HKLMregistryPath -Name 'DisablePersonalSync' -Value 1 -Type "DWORD"
Set-RegistryValue -Path $HKLMregistryPath -Name 'FilesOnDemandEnabled' -Value 1 -Type "DWORD"
Set-RegistryValue -Path $HKLMregistryPath -Name 'KFMSilentOptIn' -Value $TenantGUID -Type "String"
Set-RegistryValue -Path $HKLMregistryPath -Name 'KFMSilentOptInWithNotification' -Value 1 -Type "DWORD"

Write-Host "  ✓ OneDrive configured for business use" -ForegroundColor Green
Write-Host "    - Silent account configuration enabled" -ForegroundColor Gray
Write-Host "    - Personal OneDrive disabled" -ForegroundColor Gray
Write-Host "    - Files on Demand enabled" -ForegroundColor Gray
Write-Host "    - Known Folder Move (KFM) enabled" -ForegroundColor Gray

#endregion

#region Windows Hello for Business

Write-Host "`n=== Configuring Windows Hello for Business ===" -ForegroundColor Cyan

$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork'

if (!(Test-Path $HKLMregistryPath)) {
    New-Item -Path $HKLMregistryPath -Force | Out-Null
}

Set-RegistryValue -Path $HKLMregistryPath -Name 'Enabled' -Value 1 -Type "DWORD"
Set-RegistryValue -Path $HKLMregistryPath -Name 'DisablePostLogonProvisioning' -Value 1 -Type "DWORD"

Write-Host "  ✓ Windows Hello for Business enabled" -ForegroundColor Green

#endregion

#region Post-Installation Configuration

Write-Host "`n=== Post-Installation Configuration ===" -ForegroundColor Cyan

# Remove Personal Teams App (conflicts with Teams for Work)
if ($null -eq (Get-AppxPackage -Name "MicrosoftTeams" -AllUsers)) {
    Write-Host "  ✓ Microsoft Teams Personal App not present" -ForegroundColor Green
}
else {
    Write-Host "Removing Microsoft Teams Personal App..." -ForegroundColor Yellow
    try {
        Get-AppxPackage -Name "MicrosoftTeams" -AllUsers | Remove-AppxPackage -AllUsers
        Write-Host "  ✓ Microsoft Teams Personal App removed" -ForegroundColor Green
    }
    catch {
        Write-Warning "  ✗ Failed to remove Microsoft Teams Personal App"
    }
}

# Create scheduled task for winget updates
Write-Host "Creating scheduled task for automatic updates..." -ForegroundColor Yellow
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"winget upgrade --all --silent --accept-package-agreements --accept-source-agreements`""
$trigger = New-ScheduledTaskTrigger -Daily -At 4:00AM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "WingetAutoUpdate" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
Write-Host "  ✓ Daily automatic updates scheduled for 4:00 AM" -ForegroundColor Green

#endregion

#region Windows Updates

Write-Host "`n=== Installing Windows Updates ===" -ForegroundColor Cyan

# Enable Microsoft Update
$MU = New-Object -ComObject Microsoft.Update.ServiceManager
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
Write-Host "  ✓ Microsoft Update enabled" -ForegroundColor Green

# Install PSWindowsUpdate module if not present
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
}

# Install Windows Updates
Write-Host "Checking for Windows Updates (this may take a while)..." -ForegroundColor Yellow
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

#endregion

Write-Host "`n=== OOBE Setup Complete! ===" -ForegroundColor Green
Write-Host "A restart may be required to complete installation of some features." -ForegroundColor Yellow
Write-Host ""
