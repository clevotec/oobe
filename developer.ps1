#Requires -RunAsAdministrator

<#
.SYNOPSIS
    OOBE Setup Script - Developer Edition
.DESCRIPTION
    Modernized OOBE setup script using UniGetUI and winget for package management.
    Configures Windows and installs developer tools and applications.
.PARAMETER DirectInstall
    Skip UniGetUI and install packages directly via winget (traditional mode)
.PARAMETER BundleOnly
    Only download and open the bundle in UniGetUI, skip direct package installation
.EXAMPLE
    .\developer.ps1
    # Installs UniGetUI first, then opens the package bundle for installation
.EXAMPLE
    .\developer.ps1 -DirectInstall
    # Traditional mode: installs packages directly via winget without UniGetUI
#>

param(
    [switch]$DirectInstall,
    [switch]$BundleOnly
)

$Edition = "developer"
$BundleUrl = "https://raw.githubusercontent.com/clevotec/oobe/main/bundles/developer.ubundle"
$BundlePath = "$env:TEMP\oobe-developer.ubundle"

Write-Host "=== Developer OOBE Setup Script ===" -ForegroundColor Cyan
Write-Host "Powered by UniGetUI and winget package management" -ForegroundColor Green
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

function Install-UniGetUI {
    Write-Host "`n=== Installing UniGetUI ===" -ForegroundColor Cyan

    # Check if UniGetUI is already installed
    $unigetui = Get-Command "UniGetUI.exe" -ErrorAction SilentlyContinue
    if ($null -eq $unigetui) {
        $unigetui = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                    Where-Object { $_.DisplayName -like "*UniGetUI*" }
    }

    if ($null -ne $unigetui) {
        Write-Host "  ✓ UniGetUI is already installed" -ForegroundColor Green
        return $true
    }

    Write-Host "Installing UniGetUI (formerly WingetUI)..." -ForegroundColor Yellow
    try {
        winget install --id MartiCliment.UniGetUI --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Host "  ✓ UniGetUI installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "  ✗ Failed to install UniGetUI: $_"
        return $false
    }
}

function Get-PackageBundle {
    param(
        [string]$Url,
        [string]$DestinationPath
    )

    Write-Host "Downloading package bundle..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $Url -OutFile $DestinationPath -UseBasicParsing
        Write-Host "  ✓ Bundle downloaded to $DestinationPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "  ✗ Failed to download bundle: $_"
        return $false
    }
}

function Open-UniGetUIBundle {
    param(
        [string]$BundlePath
    )

    Write-Host "Opening bundle in UniGetUI..." -ForegroundColor Yellow

    # Find UniGetUI executable
    $unigetuiPaths = @(
        "$env:LOCALAPPDATA\Programs\UniGetUI\UniGetUI.exe",
        "$env:ProgramFiles\UniGetUI\UniGetUI.exe",
        "${env:ProgramFiles(x86)}\UniGetUI\UniGetUI.exe"
    )

    $unigetuiExe = $null
    foreach ($path in $unigetuiPaths) {
        if (Test-Path $path) {
            $unigetuiExe = $path
            break
        }
    }

    if ($null -eq $unigetuiExe) {
        # Try to find via where command
        $unigetuiExe = (Get-Command "UniGetUI.exe" -ErrorAction SilentlyContinue).Source
    }

    if ($null -ne $unigetuiExe -and (Test-Path $unigetuiExe)) {
        Write-Host "  Starting UniGetUI with bundle..." -ForegroundColor Yellow
        Start-Process -FilePath $unigetuiExe -ArgumentList "`"$BundlePath`""
        Write-Host "  ✓ UniGetUI launched - Please review and install packages from the bundle" -ForegroundColor Green
        Write-Host "  ⓘ The bundle contains all packages for the $Edition edition" -ForegroundColor Gray
        return $true
    }
    else {
        Write-Warning "  ✗ Could not find UniGetUI executable"
        return $false
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

# Show File Extensions
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Show Hidden Files and Folders
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Disable Search Box on Taskbar (use icon only)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1

# Enable Dark Theme
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Write-Host "  ✓ Dark theme enabled" -ForegroundColor Green

# Enable Windows Spotlight for Desktop Background
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "BackgroundType" -Value 2
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1
# Enable Windows Spotlight on lock screen
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 1
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 1
Write-Host "  ✓ Windows Spotlight enabled for desktop and lock screen" -ForegroundColor Green

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Host "  ✓ Remote Desktop enabled" -ForegroundColor Green

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

if (-not $DirectInstall) {
    # UniGetUI Mode (Default) - Install UniGetUI and use bundle
    Write-Host "`n=== UniGetUI Package Installation ===" -ForegroundColor Cyan

    $unigetInstalled = Install-UniGetUI
    if ($unigetInstalled) {
        $bundleDownloaded = Get-PackageBundle -Url $BundleUrl -DestinationPath $BundlePath
        if ($bundleDownloaded) {
            # Give UniGetUI time to finish installation
            Start-Sleep -Seconds 2

            $bundleOpened = Open-UniGetUIBundle -BundlePath $BundlePath
            if ($bundleOpened) {
                Write-Host "`n  ✓ UniGetUI launched with package bundle" -ForegroundColor Green
                Write-Host "  ⓘ Review the packages in UniGetUI and click 'Install' to proceed" -ForegroundColor Gray
                Write-Host "  ⓘ UniGetUI provides a GUI to manage, update, and uninstall packages" -ForegroundColor Gray

                if ($BundleOnly) {
                    Write-Host "`n=== Bundle-Only Mode ===" -ForegroundColor Cyan
                    Write-Host "  Skipping direct package installation as requested." -ForegroundColor Gray
                    Write-Host "  Please complete installation in UniGetUI." -ForegroundColor Gray
                }
            }
            else {
                Write-Warning "  Falling back to direct winget installation..."
                $DirectInstall = $true
            }
        }
        else {
            Write-Warning "  Failed to download bundle. Falling back to direct winget installation..."
            $DirectInstall = $true
        }
    }
    else {
        Write-Warning "  Failed to install UniGetUI. Falling back to direct winget installation..."
        $DirectInstall = $true
    }
}

if ($DirectInstall) {
    # Direct Winget Mode - Traditional installation
    Write-Host "`n=== Installing Packages via Winget ===" -ForegroundColor Cyan

    # Utilities
    Install-WingetPackage -PackageId "7zip.7zip" -Name "7-Zip"
    Install-WingetPackage -PackageId "Google.PlatformTools" -Name "Android Debug Bridge (ADB)"
    Install-WingetPackage -PackageId "Git.Git" -Name "Git"
    Install-WingetPackage -PackageId "Microsoft.Sysinternals.Suite" -Name "Sysinternals Suite"
    Install-WingetPackage -PackageId "WinSCP.WinSCP" -Name "WinSCP"
    Install-WingetPackage -PackageId "Microsoft.PowerToys" -Name "PowerToys"

    # Browsers
    Install-WingetPackage -PackageId "Brave.Brave" -Name "Brave Browser"
    Install-WingetPackage -PackageId "Mozilla.Firefox" -Name "Firefox"
    Install-WingetPackage -PackageId "Google.Chrome" -Name "Google Chrome"
    Install-WingetPackage -PackageId "Microsoft.Edge" -Name "Microsoft Edge"

    # Development Tools
    Install-WingetPackage -PackageId "Microsoft.VisualStudioCode" -Name "Visual Studio Code"
    Install-WingetPackage -PackageId "Notepad++.Notepad++" -Name "Notepad++"
    Install-WingetPackage -PackageId "TortoiseGit.TortoiseGit" -Name "TortoiseGit"
    Install-WingetPackage -PackageId "Genymobile.scrcpy" -Name "scrcpy"
    Install-WingetPackage -PackageId "Microsoft.WindowsTerminal" -Name "Windows Terminal"

    # Creative Tools
    Install-WingetPackage -PackageId "GIMP.GIMP" -Name "GIMP"
    Install-WingetPackage -PackageId "Inkscape.Inkscape" -Name "Inkscape"
    Install-WingetPackage -PackageId "Obsidian.Obsidian" -Name "Obsidian"

    # Media Tools
    Install-WingetPackage -PackageId "Gyan.FFmpeg" -Name "FFmpeg"
    Install-WingetPackage -PackageId "yt-dlp.yt-dlp" -Name "yt-dlp"
    Install-WingetPackage -PackageId "VideoLAN.VLC" -Name "VLC Media Player"
    Install-WingetPackage -PackageId "9NBLGGH6X7MR" -Name "Tidal" -Source "msstore"

    # Communication
    Install-WingetPackage -PackageId "Telegram.TelegramDesktop" -Name "Telegram"
    Install-WingetPackage -PackageId "Mozilla.Thunderbird" -Name "Thunderbird"
    Install-WingetPackage -PackageId "Microsoft.Teams" -Name "Microsoft Teams"

    # Security & Sync
    Install-WingetPackage -PackageId "KeePassXCTeam.KeePassXC" -Name "KeePassXC"
    Install-WingetPackage -PackageId "SyncTrayzor.SyncTrayzor" -Name "SyncTrayzor"
    Install-WingetPackage -PackageId "tailscale.tailscale" -Name "Tailscale"

    # Office & Productivity
    Install-WingetPackage -PackageId "TheDocumentFoundation.LibreOffice" -Name "LibreOffice"
    Install-WingetPackage -PackageId "Microsoft.Office" -Name "Microsoft Office"
    Install-WingetPackage -PackageId "Foxit.FoxitReader" -Name "Foxit PDF Reader"

    Write-Host "`n  ✓ Package installation complete" -ForegroundColor Green
}

#endregion

#region Windows Features

Write-Host "`n=== Installing Windows Features ===" -ForegroundColor Cyan

# Install Hyper-V
$hypervState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Hyper-V-All" -Online)
if ($hypervState.State -eq 'Enabled') {
    Write-Host "  ✓ Hyper-V already installed" -ForegroundColor Green
}
else {
    Write-Host "Installing Hyper-V..." -ForegroundColor Yellow
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -All
        Write-Host "  ✓ Hyper-V installed" -ForegroundColor Green
    }
    catch {
        Write-Warning "  ✗ Failed to install Hyper-V (requires Windows 10/11 Pro/Enterprise)"
    }
}

# Install Windows Sandbox
$sandboxState = (Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online)
if ($sandboxState.State -eq 'Enabled') {
    Write-Host "  ✓ Windows Sandbox already installed" -ForegroundColor Green
}
else {
    Write-Host "Installing Windows Sandbox..." -ForegroundColor Yellow
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -NoRestart -All
        Write-Host "  ✓ Windows Sandbox installed" -ForegroundColor Green
    }
    catch {
        Write-Warning "  ✗ Failed to install Windows Sandbox (requires Windows 10/11 Pro/Enterprise)"
    }
}

# Install WSL
$wslState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online)
if ($wslState.State -eq 'Enabled') {
    Write-Host "  ✓ WSL already installed" -ForegroundColor Green
}
else {
    Write-Host "Installing WSL..." -ForegroundColor Yellow
    try {
        wsl --install -d Ubuntu --no-launch
        Write-Host "  ✓ WSL with Ubuntu installed" -ForegroundColor Green
    }
    catch {
        Write-Warning "  ✗ Failed to install WSL"
    }
}

#endregion

#region Post-Installation Configuration

Write-Host "`n=== Post-Installation Configuration ===" -ForegroundColor Cyan

# Pin Firefox to Taskbar
$firefoxPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    Write-Host "Pinning Firefox to taskbar..." -ForegroundColor Yellow
    # Note: Taskbar pinning via script is restricted in modern Windows
    # Users will need to pin manually or use Group Policy
    Write-Host "  ⓘ Please pin Firefox to taskbar manually" -ForegroundColor Gray
}

# Replace Notepad with Notepad++
$notepadPPPath = "${env:ProgramFiles}\Notepad++\notepad++.exe"
if (Test-Path $notepadPPPath) {
    Write-Host "Configuring Notepad++ as default notepad..." -ForegroundColor Yellow
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" -Name "Debugger" -Value "`"$notepadPPPath`" -notepadStyleCmdline -z" -Type "String"
    Write-Host "  ✓ Notepad++ configured as default" -ForegroundColor Green
}

# Configure KeePassXC Browser Extensions
Write-Host "Configuring KeePassXC browser extensions..." -ForegroundColor Yellow
# KeePassXC Browser Extension IDs
$chromeExtId = "oboonakemofpalcgghocfoadofidjkkk"  # Chrome/Edge/Brave
$firefoxExtId = "{ff27e49b-4e79-4e00-8bea-92c2c00f4d7f}"

# Install extension for Chrome
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"

# Install extension for Edge
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"

# Install extension for Brave (uses Chrome Web Store)
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"

Write-Host "  ✓ KeePassXC browser extensions configured for Chrome, Edge, and Brave" -ForegroundColor Green
Write-Host "  ⓘ For Firefox: Install manually from https://addons.mozilla.org/firefox/addon/keepassxc-browser/" -ForegroundColor Gray

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
