<#
.SYNOPSIS
    Common helper functions for OOBE Setup Scripts
.DESCRIPTION
    Contains shared functions for package installation, registry manipulation,
    Windows configuration, and Chocolatey migration.
#>

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
        $result = winget install --id $PackageId --source $Source --silent --accept-package-agreements --accept-source-agreements 2>&1
        if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
            Write-Host "  [OK] $Name installed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "  [X] Failed to install $Name"
            return $false
        }
    }
    catch {
        Write-Warning "  [X] Failed to install $Name : $_"
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

#region Chocolatey Migration

function Invoke-ChocolateyMigration {
    Write-Host "`n=== Checking for Chocolatey Installation ===" -ForegroundColor Cyan

    $chocoPath = $env:ChocolateyInstall
    if ($chocoPath -and (Test-Path $chocoPath)) {
        Write-Host "  Chocolatey detected at '$chocoPath'" -ForegroundColor Yellow
        Write-Host "  Running Chocolatey uninstaller to migrate to winget..." -ForegroundColor Yellow

        try {
            $uninstallScript = "$env:TEMP\uninstall-chocolatey.ps1"
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clevotec/oobe/main/uninstall-chocolatey.ps1' -OutFile $uninstallScript
            & $uninstallScript
            Remove-Item -Path $uninstallScript -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] Chocolatey migration complete" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "  [X] Failed to run Chocolatey uninstaller: $_"
            Write-Warning "  You may need to manually uninstall Chocolatey"
            return $false
        }
    }
    else {
        Write-Host "  [OK] Chocolatey not installed (using winget)" -ForegroundColor Green
        return $true
    }
}

#endregion

#region Windows Configuration

function Set-CommonWindowsSettings {
    Write-Host "`n=== Configuring Windows Settings ===" -ForegroundColor Cyan

    # Disable Bing Search in Start Menu
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0

    # Disable Game Bar Tips
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Value 0

    # Disable Search Box on Taskbar (use icon only)
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1

    # Enable Dark Theme
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    Write-Host "  [OK] Dark theme enabled" -ForegroundColor Green

    # Enable Windows Spotlight for Desktop Background
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "BackgroundType" -Value 2
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1
    # Enable Windows Spotlight on lock screen
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 1
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 1
    Write-Host "  [OK] Windows Spotlight enabled for desktop and lock screen" -ForegroundColor Green

    Write-Host "  [OK] Windows configuration complete" -ForegroundColor Green
}

function Set-FileExplorerSettings {
    param(
        [bool]$ShowFileExtensions = $true,
        [bool]$ShowHiddenFiles = $false
    )

    if ($ShowFileExtensions) {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    }
    else {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1
    }

    if ($ShowHiddenFiles) {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
    }
    else {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 2
    }
}

function Enable-RemoteDesktop {
    Write-Host "Enabling Remote Desktop..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    Write-Host "  [OK] Remote Desktop enabled" -ForegroundColor Green
}

#endregion

#region Winget Setup

function Test-WingetAvailable {
    Write-Host "`n=== Verifying Winget Installation ===" -ForegroundColor Cyan

    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed. Please install App Installer from the Microsoft Store or ensure you're running Windows 10 1809+ or Windows 11."
        return $false
    }

    Write-Host "  [OK] Winget is available" -ForegroundColor Green

    # Update winget sources
    Write-Host "Updating winget sources..." -ForegroundColor Yellow
    winget source update | Out-Null

    return $true
}

#endregion

#region OneDrive Configuration

function Set-OneDriveForBusiness {
    param(
        [string]$TenantGUID
    )

    Write-Host "`n=== Configuring OneDrive for Business ===" -ForegroundColor Cyan

    $HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'

    if (!(Test-Path $HKLMregistryPath)) {
        New-Item -Path $HKLMregistryPath -Force | Out-Null
    }

    Set-RegistryValue -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value 1 -Type "DWORD"
    Set-RegistryValue -Path $HKLMregistryPath -Name 'DisablePersonalSync' -Value 1 -Type "DWORD"
    Set-RegistryValue -Path $HKLMregistryPath -Name 'FilesOnDemandEnabled' -Value 1 -Type "DWORD"
    Set-RegistryValue -Path $HKLMregistryPath -Name 'KFMSilentOptIn' -Value $TenantGUID -Type "String"
    Set-RegistryValue -Path $HKLMregistryPath -Name 'KFMSilentOptInWithNotification' -Value 1 -Type "DWORD"

    Write-Host "  [OK] OneDrive configured for business use" -ForegroundColor Green
    Write-Host "    - Silent account configuration enabled" -ForegroundColor Gray
    Write-Host "    - Personal OneDrive disabled" -ForegroundColor Gray
    Write-Host "    - Files on Demand enabled" -ForegroundColor Gray
    Write-Host "    - Known Folder Move (KFM) enabled" -ForegroundColor Gray
}

#endregion

#region Windows Hello

function Enable-WindowsHelloForBusiness {
    param(
        [bool]$DisablePostLogonProvisioning = $false
    )

    Write-Host "`n=== Configuring Windows Hello for Business ===" -ForegroundColor Cyan

    $HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork'

    if (!(Test-Path $HKLMregistryPath)) {
        New-Item -Path $HKLMregistryPath -Force | Out-Null
    }

    Set-RegistryValue -Path $HKLMregistryPath -Name 'Enabled' -Value 1 -Type "DWORD"

    if ($DisablePostLogonProvisioning) {
        Set-RegistryValue -Path $HKLMregistryPath -Name 'DisablePostLogonProvisioning' -Value 1 -Type "DWORD"
    }

    Write-Host "  [OK] Windows Hello for Business enabled" -ForegroundColor Green
}

#endregion

#region Post-Installation

function Set-NotepadPlusPlusAsDefault {
    $notepadPPPath = "${env:ProgramFiles}\Notepad++\notepad++.exe"
    if (Test-Path $notepadPPPath) {
        Write-Host "Configuring Notepad++ as default notepad..." -ForegroundColor Yellow
        Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" -Name "Debugger" -Value "`"$notepadPPPath`" -notepadStyleCmdline -z" -Type "String"
        Write-Host "  [OK] Notepad++ configured as default" -ForegroundColor Green
    }
}

function Set-KeePassXCBrowserExtensions {
    param(
        [bool]$Chrome = $false,
        [bool]$Edge = $true,
        [bool]$Brave = $true
    )

    Write-Host "Configuring KeePassXC browser extensions..." -ForegroundColor Yellow
    $chromeExtId = "oboonakemofpalcgghocfoadofidjkkk"

    if ($Chrome) {
        Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"
    }

    if ($Edge) {
        Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"
    }

    if ($Brave) {
        Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtId;https://clients2.google.com/service/update2/crx" -Type "String"
    }

    $browsers = @()
    if ($Chrome) { $browsers += "Chrome" }
    if ($Edge) { $browsers += "Edge" }
    if ($Brave) { $browsers += "Brave" }

    Write-Host "  [OK] KeePassXC browser extensions configured for $($browsers -join ', ')" -ForegroundColor Green
    Write-Host "  (i) For Firefox: Install manually from https://addons.mozilla.org/firefox/addon/keepassxc-browser/" -ForegroundColor Gray
}

function Remove-PersonalTeamsApp {
    if ($null -eq (Get-AppxPackage -Name "MicrosoftTeams" -AllUsers -ErrorAction SilentlyContinue)) {
        Write-Host "  [OK] Microsoft Teams Personal App not present" -ForegroundColor Green
    }
    else {
        Write-Host "Removing Microsoft Teams Personal App..." -ForegroundColor Yellow
        try {
            Get-AppxPackage -Name "MicrosoftTeams" -AllUsers | Remove-AppxPackage -AllUsers
            Write-Host "  [OK] Microsoft Teams Personal App removed" -ForegroundColor Green
        }
        catch {
            Write-Warning "  [X] Failed to remove Microsoft Teams Personal App"
        }
    }
}

function Register-WingetAutoUpdate {
    Write-Host "Creating scheduled task for automatic updates..." -ForegroundColor Yellow
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"winget upgrade --all --silent --accept-package-agreements --accept-source-agreements`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 4:00AM
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName "WingetAutoUpdate" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "  [OK] Daily automatic updates scheduled for 4:00 AM" -ForegroundColor Green
}

#endregion

#region Windows Features

function Install-WindowsFeature {
    param(
        [string]$FeatureName,
        [string]$DisplayName
    )

    $featureState = (Get-WindowsOptionalFeature -FeatureName $FeatureName -Online -ErrorAction SilentlyContinue)
    if ($featureState.State -eq 'Enabled') {
        Write-Host "  [OK] $DisplayName already installed" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Installing $DisplayName..." -ForegroundColor Yellow
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -All -ErrorAction Stop | Out-Null
            Write-Host "  [OK] $DisplayName installed" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "  [X] Failed to install $DisplayName (requires Windows 10/11 Pro/Enterprise)"
            return $false
        }
    }
}

function Install-WSL {
    $wslState = (Get-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online -ErrorAction SilentlyContinue)
    if ($wslState.State -eq 'Enabled') {
        Write-Host "  [OK] WSL already installed" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Installing WSL..." -ForegroundColor Yellow
        try {
            wsl --install -d Ubuntu --no-launch 2>&1 | Out-Null
            Write-Host "  [OK] WSL with Ubuntu installed" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "  [X] Failed to install WSL"
            return $false
        }
    }
}

#endregion

#region Windows Updates

function Install-WindowsUpdates {
    Write-Host "`n=== Installing Windows Updates ===" -ForegroundColor Cyan

    # Enable Microsoft Update
    try {
        $MU = New-Object -ComObject Microsoft.Update.ServiceManager
        $MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") | Out-Null
        Write-Host "  [OK] Microsoft Update enabled" -ForegroundColor Green
    }
    catch {
        Write-Warning "  [X] Failed to enable Microsoft Update"
    }

    # Install PSWindowsUpdate module if not present
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
            Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
        }
        catch {
            Write-Warning "  [X] Failed to install PSWindowsUpdate module"
            return
        }
    }

    # Install Windows Updates
    Write-Host "Checking for Windows Updates (this may take a while)..." -ForegroundColor Yellow
    try {
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot
    }
    catch {
        Write-Warning "  [X] Failed to install Windows Updates: $_"
    }
}

#endregion
