# Windows OOBE Setup Scripts

Automated Windows Out-of-Box Experience (OOBE) setup scripts using modern `winget` package management. These scripts configure Windows settings and install applications for different use cases.

## Overview

These PowerShell scripts automate the initial setup of Windows workstations with preconfigured packages and settings. All scripts use **winget** (Windows Package Manager) for reliable, modern package management.

## Requirements

- Windows 10 (1809+) or Windows 11
- PowerShell 5.1 or later
- Administrator privileges
- Windows Package Manager (winget) - Pre-installed on Windows 11 and modern Windows 10 builds
- Internet connection

## Scripts

### 1. Standard Edition (`standard.ps1`)

**Purpose:** General office and creative workstation setup with business productivity tools.

**Target Users:** Office workers, content creators, general business users

**Features:**
- Configures Windows settings (dark theme, file extensions, Windows Spotlight)
- Installs essential browsers, office suite, and communication tools
- Sets up OneDrive for Business with Known Folder Move
- Configures Windows Hello for Business
- Installs creative and media tools
- Sets up automatic updates via scheduled task

**Software Installed via Winget:**

| Category | Software | Winget Package ID |
|----------|----------|-------------------|
| **Utilities** | 7-Zip | `7zip.7zip` |
| **Browsers** | Google Chrome | `Google.Chrome` |
| | Brave Browser | `Brave.Brave` |
| | Mozilla Firefox | `Mozilla.Firefox` |
| | Microsoft Edge | `Microsoft.Edge` |
| **Communication** | Microsoft Teams | `Microsoft.Teams` |
| | Skype | `Microsoft.Skype` |
| **Office & Productivity** | Microsoft Office 365 Business | `Microsoft.Office` |
| | Foxit PDF Reader | `Foxit.FoxitReader` |
| | LibreOffice | `TheDocumentFoundation.LibreOffice` |
| **Hardware Support** | Jabra Direct | `Jabra.Direct` |
| **Security** | KeePassXC | `KeePassXCTeam.KeePassXC` |
| **Media Tools** | VLC Media Player | `VideoLAN.VLC` |
| | FFmpeg | `Gyan.FFmpeg` |
| | yt-dlp | `yt-dlp.yt-dlp` |
| | OBS Studio | `OBSProject.OBSStudio` |
| **Creative Tools** | GIMP | `GIMP.GIMP` |
| | Inkscape | `Inkscape.Inkscape` |
| **Development** | Windows Terminal | `Microsoft.WindowsTerminal` |
| | Visual Studio Code | `Microsoft.VisualStudioCode` |
| | Notepad++ | `Notepad++.Notepad++` |
| **Networking** | Tailscale | `tailscale.tailscale` |

**PowerShell Execution:**

```powershell
# Download and execute directly from GitHub
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/clevotec/oobe/main/standard.ps1'))
```

```powershell
# Or download first, then execute locally
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clevotec/oobe/main/standard.ps1' -OutFile "$env:TEMP\standard.ps1"
Set-ExecutionPolicy Bypass -Scope Process -Force
& "$env:TEMP\standard.ps1"
```

```powershell
# If you have the repository cloned locally
cd C:\path\to\oobe
Set-ExecutionPolicy Bypass -Scope Process -Force
.\standard.ps1
```

---

### 2. Business Edition (`business.ps1`)

**Purpose:** Streamlined business workstation with essential productivity tools.

**Target Users:** Business professionals, corporate employees, office administrators

**Features:**
- Minimal, focused software selection for business use
- Hides file extensions and hidden files (business preference)
- Configures OneDrive for Business with tenant-specific settings
- Enables Windows Hello for Business with post-logon provisioning disabled
- Auto-configures KeePassXC browser extensions for Edge and Brave
- Sets up automatic daily updates at 4:00 AM

**Software Installed via Winget:**

| Category | Software | Winget Package ID |
|----------|----------|-------------------|
| **Utilities** | 7-Zip | `7zip.7zip` |
| **Browsers** | Brave Browser | `Brave.Brave` |
| | Microsoft Edge | `Microsoft.Edge` |
| **Communication** | Microsoft Teams | `Microsoft.Teams` |
| | Zoom | `Zoom.Zoom` |
| **Office & Productivity** | Microsoft Office | `Microsoft.Office` |
| | Adobe Acrobat Reader | `Adobe.Acrobat.Reader.64-bit` |
| | Foxit PDF Reader | `Foxit.FoxitReader` |
| **Security** | KeePassXC | `KeePassXCTeam.KeePassXC` |
| **Media** | VLC Media Player | `VideoLAN.VLC` |

**PowerShell Execution:**

```powershell
# Download and execute directly from GitHub
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/clevotec/oobe/main/business.ps1'))
```

```powershell
# Or download first, then execute locally
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clevotec/oobe/main/business.ps1' -OutFile "$env:TEMP\business.ps1"
Set-ExecutionPolicy Bypass -Scope Process -Force
& "$env:TEMP\business.ps1"
```

```powershell
# If you have the repository cloned locally
cd C:\path\to\oobe
Set-ExecutionPolicy Bypass -Scope Process -Force
.\business.ps1
```

---

### 3. Developer Edition (`developer.ps1`)

**Purpose:** Comprehensive development workstation with full toolset for developers.

**Target Users:** Software developers, system administrators, IT professionals, power users

**Features:**
- Shows file extensions and hidden files for development work
- Enables Remote Desktop with firewall rules
- Installs Windows Subsystem for Linux (WSL) with Ubuntu
- Enables Hyper-V and Windows Sandbox (requires Pro/Enterprise)
- Comprehensive development tools and utilities
- Multiple browsers for cross-platform testing
- Configures Notepad++ as default notepad replacement
- Pins Firefox to taskbar (manual step required)
- Auto-configures KeePassXC browser extensions for Chrome, Edge, and Brave

**Software Installed via Winget:**

| Category | Software | Winget Package ID |
|----------|----------|-------------------|
| **Utilities** | 7-Zip | `7zip.7zip` |
| | Android Debug Bridge (ADB) | `Google.PlatformTools` |
| | Git | `Git.Git` |
| | Sysinternals Suite | `Microsoft.Sysinternals.Suite` |
| | WinSCP | `WinSCP.WinSCP` |
| | PowerToys | `Microsoft.PowerToys` |
| **Browsers** | Brave Browser | `Brave.Brave` |
| | Mozilla Firefox | `Mozilla.Firefox` |
| | Google Chrome | `Google.Chrome` |
| | Microsoft Edge | `Microsoft.Edge` |
| **Development Tools** | Visual Studio Code | `Microsoft.VisualStudioCode` |
| | Notepad++ | `Notepad++.Notepad++` |
| | TortoiseGit | `TortoiseGit.TortoiseGit` |
| | scrcpy | `Genymobile.scrcpy` |
| | Windows Terminal | `Microsoft.WindowsTerminal` |
| **Creative Tools** | GIMP | `GIMP.GIMP` |
| | Inkscape | `Inkscape.Inkscape` |
| | Obsidian | `Obsidian.Obsidian` |
| **Media Tools** | FFmpeg | `Gyan.FFmpeg` |
| | yt-dlp | `yt-dlp.yt-dlp` |
| | VLC Media Player | `VideoLAN.VLC` |
| | Tidal | `9NBLGGH6X7MR` (Microsoft Store) |
| **Communication** | Skype | `Microsoft.Skype` |
| | Telegram Desktop | `Telegram.TelegramDesktop` |
| | Thunderbird | `Mozilla.Thunderbird` |
| | Microsoft Teams | `Microsoft.Teams` |
| **Security & Sync** | KeePassXC | `KeePassXCTeam.KeePassXC` |
| | SyncTrayzor | `SyncTrayzor.SyncTrayzor` |
| | Tailscale | `tailscale.tailscale` |
| **Office & Productivity** | LibreOffice | `TheDocumentFoundation.LibreOffice` |
| | Microsoft Office | `Microsoft.Office` |
| | Foxit PDF Reader | `Foxit.FoxitReader` |

**Windows Features Enabled:**
- Hyper-V (`Microsoft-Hyper-V-All`)
- Windows Sandbox (`Containers-DisposableClientVM`)
- Windows Subsystem for Linux with Ubuntu

**PowerShell Execution:**

```powershell
# Download and execute directly from GitHub
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/clevotec/oobe/main/developer.ps1'))
```

```powershell
# Or download first, then execute locally
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clevotec/oobe/main/developer.ps1' -OutFile "$env:TEMP\developer.ps1"
Set-ExecutionPolicy Bypass -Scope Process -Force
& "$env:TEMP\developer.ps1"
```

```powershell
# If you have the repository cloned locally
cd C:\path\to\oobe
Set-ExecutionPolicy Bypass -Scope Process -Force
.\developer.ps1
```

---

## Common Features (All Scripts)

All scripts include the following configurations:

### Windows Settings
- **Disable Bing Search** in Start Menu
- **Disable Game Bar Tips**
- **Enable Dark Theme** for apps and system
- **Enable Windows Spotlight** for desktop and lock screen
- **Disable Search Box** on taskbar (icon only mode)

### Automation
- **Automatic Updates:** Scheduled task runs daily at 4:00 AM to update all winget packages
- **Windows Updates:** Installs all available Windows updates using PSWindowsUpdate module
- **Microsoft Update:** Enables Microsoft Update for drivers and other Microsoft products

### Security & Authentication
- **Windows Hello for Business:** Enabled and configured
- **OneDrive for Business:** Configured with Files on Demand and Known Folder Move (standard.ps1 and business.ps1)
- **KeePassXC Browser Integration:** Automatically configures browser extensions for password management

### Cleanup
- Removes Personal Microsoft Teams app (conflicts with Teams for Work/School)

---

## Usage Instructions

### Prerequisites Check

Before running any script, verify your system meets the requirements:

```powershell
# Check Windows version
Get-ComputerInfo | Select-Object WindowsVersion, OsHardwareAbstractionLayer

# Check if winget is available
winget --version

# Verify PowerShell version
$PSVersionTable.PSVersion
```

### Running Scripts

1. **Open PowerShell as Administrator**
   - Right-click Start Menu → Windows Terminal (Admin) or PowerShell (Admin)

2. **Choose your execution method** from the examples above for your target script

3. **Wait for completion**
   - The script will display progress for each installation
   - Some packages may require user interaction
   - The process may take 30-60 minutes depending on your internet connection

4. **Restart when prompted**
   - A restart is typically required to complete installation of Windows features and updates

### Post-Installation

After running the script and restarting:

1. **OneDrive Sign-In** (standard.ps1 and business.ps1)
   - Sign in to OneDrive with your organizational account
   - Known Folder Move will automatically backup Desktop, Documents, and Pictures

2. **Windows Hello Setup**
   - Set up PIN, fingerprint, or facial recognition when prompted

3. **Browser Extensions**
   - KeePassXC extensions are pre-configured for Chrome, Edge, and Brave
   - Firefox users: Manually install from https://addons.mozilla.org/firefox/addon/keepassxc-browser/

4. **WSL Setup** (developer.ps1 only)
   - Launch Ubuntu from Start Menu to complete initial setup
   - Create your Linux username and password

---

## Customization

### Modifying OneDrive Tenant

To use with your organization's OneDrive, update the `$TenantGUID` variable in the script:

```powershell
# Find your tenant ID at: https://portal.azure.com → Azure Active Directory → Properties
$TenantGUID = 'your-tenant-guid-here'
```

### Adding/Removing Packages

To add additional packages, use the helper function:

```powershell
Install-WingetPackage -PackageId "Publisher.AppName" -Name "Friendly Name"
```

To find package IDs:

```powershell
winget search "application name"
```

### Disabling Automatic Updates

To remove the automatic update scheduled task:

```powershell
Unregister-ScheduledTask -TaskName "WingetAutoUpdate" -Confirm:$false
```

---

## Troubleshooting

### Winget Not Found

If winget is not available:

```powershell
# Install App Installer from Microsoft Store
Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"

# Or download directly from GitHub
# https://github.com/microsoft/winget-cli/releases
```

### Script Execution Policy Error

```powershell
# Temporarily bypass execution policy for current session
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Package Installation Failures

If individual packages fail to install:

```powershell
# Manually install failed package
winget install --id PackageId --source winget

# Update winget sources
winget source update

# Reset winget
winget source reset --force
```

### Windows Features Installation Failures

Some features require Windows 10/11 Pro or Enterprise:
- Hyper-V
- Windows Sandbox

These will fail gracefully on Home editions with a warning message.

---

## Migration from Chocolatey

These scripts replace the older Chocolatey-based versions with native winget support:

- **Old:** `cand.ps1` → **New:** `standard.ps1`
- **Old:** N/A → **New:** `business.ps1`
- **Old:** `kcrk.ps1` → **New:** `developer.ps1`

### Why Winget?

- Native to Windows 10/11 (no third-party installation required)
- Official Microsoft package manager
- Better integration with Windows Update and Store
- More reliable package sources
- Improved security with signed packages

---

## Contributing

To contribute or report issues:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

---

## License

This project is provided as-is for use in configuring Windows workstations. Modify as needed for your organization's requirements.

---

## Security Notice

These scripts:
- Require administrator privileges
- Modify system registry settings
- Install software from trusted sources (winget repositories)
- Configure organizational policies (OneDrive, Windows Hello)

**Always review scripts before execution in your environment.**

---

## Credits

Maintained by clevotec

**Previous Version:** Used Boxstarter and Chocolatey (deprecated)
**Current Version:** Native PowerShell with winget package management

---

## Quick Reference

| Script | Use Case | Package Count | Special Features |
|--------|----------|---------------|------------------|
| `standard.ps1` | Office & Creative Work | 19 packages | OneDrive KFM, Media Tools, Creative Suite |
| `business.ps1` | Business Productivity | 10 packages | Minimal, Business-focused, Quick Setup |
| `developer.ps1` | Software Development | 34 packages | WSL, Hyper-V, Sandbox, Dev Tools |

---

**Last Updated:** 2025-12-02
