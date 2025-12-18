# Windows OOBE Setup Scripts

Automated Windows Out-of-Box Experience (OOBE) setup scripts using modern `winget` package management. These scripts configure Windows settings and install applications for different use cases.

## Overview

These PowerShell scripts automate the initial setup of Windows workstations with preconfigured packages and settings. All scripts use **winget** (Windows Package Manager) for reliable, modern package management.

**New in this version:** Interactive setup with custom package selection!

## Requirements

- Windows 10 (1809+) or Windows 11
- PowerShell 5.1 or later
- Administrator privileges
- Windows Package Manager (winget) - Pre-installed on Windows 11 and modern Windows 10 builds
- Internet connection

## Quick Start

### Interactive Setup (Recommended)

Run the interactive setup wizard to choose your profile and customize packages:

```powershell
# Download and run interactive setup
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$tempDir = "$env:TEMP\oobe-setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
@('setup.ps1', 'common.ps1', 'packages.ps1') | ForEach-Object {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/clevotec/oobe/main/$_" -OutFile "$tempDir\$_"
}
& "$tempDir\setup.ps1"
```

### Non-Interactive Setup

Run a specific profile without prompts:

```powershell
# Developer profile (non-interactive)
.\setup.ps1 -Profile Developer

# Business profile, skip Windows Updates
.\setup.ps1 -Profile Business -SkipWindowsUpdates

# Standard profile, skip Chocolatey migration
.\setup.ps1 -Profile Standard -SkipChocolateyMigration
```

---

## Project Structure

```
oobe/
├── setup.ps1              # Interactive wrapper with menu system
├── common.ps1             # Shared helper functions
├── packages.ps1           # Package definitions by category
├── standard.ps1           # Standard edition (direct execution)
├── business.ps1           # Business edition (direct execution)
├── developer.ps1          # Developer edition (direct execution)
└── uninstall-chocolatey.ps1  # Chocolatey uninstaller
```

### Module Files

| File | Purpose |
|------|---------|
| `setup.ps1` | Main interactive installer with profile selection and custom package picking |
| `common.ps1` | Shared functions for package installation, Windows configuration, registry manipulation |
| `packages.ps1` | Centralized package definitions organized by category with profile mappings |

---

## Interactive Setup Features

The `setup.ps1` script provides:

1. **Profile Selection Menu**
   - Standard: Office & creative workstation (19 packages)
   - Business: Streamlined business productivity (10 packages)
   - Developer: Full development environment (34 packages)
   - Custom: Hand-pick individual packages

2. **Custom Package Selection**
   - Browse packages by category
   - Toggle individual packages on/off
   - Select all in category or all packages
   - Visual selection state with [X] markers

3. **Windows Features Selection** (Custom mode)
   - Hyper-V
   - Windows Sandbox
   - WSL + Ubuntu

4. **Installation Summary**
   - Review all selections before installing
   - Grouped display by category

---

## Profiles

### 1. Standard Edition

**Purpose:** General office and creative workstation setup

**Target Users:** Office workers, content creators, general business users

**Packages Included:**

| Category | Packages |
|----------|----------|
| **Utilities** | 7-Zip |
| **Browsers** | Chrome, Brave, Firefox, Edge |
| **Communication** | Teams, Skype |
| **Office** | Microsoft Office, Foxit Reader, LibreOffice |
| **Hardware** | Jabra Direct |
| **Security** | KeePassXC, Tailscale |
| **Media** | VLC, FFmpeg, yt-dlp, OBS Studio |
| **Creative** | GIMP, Inkscape |
| **Development** | Windows Terminal, VS Code, Notepad++ |

**Direct Execution:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$tempDir = "$env:TEMP\oobe-setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
@('standard.ps1', 'common.ps1', 'packages.ps1') | ForEach-Object {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/clevotec/oobe/main/$_" -OutFile "$tempDir\$_"
}
& "$tempDir\standard.ps1"
```

---

### 2. Business Edition

**Purpose:** Streamlined business workstation with essential productivity tools

**Target Users:** Business professionals, corporate employees

**Packages Included:**

| Category | Packages |
|----------|----------|
| **Utilities** | 7-Zip |
| **Browsers** | Brave, Edge |
| **Communication** | Teams, Zoom |
| **Office** | Microsoft Office, Adobe Reader, Foxit Reader |
| **Security** | KeePassXC |
| **Media** | VLC |

**Direct Execution:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$tempDir = "$env:TEMP\oobe-setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
@('business.ps1', 'common.ps1', 'packages.ps1') | ForEach-Object {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/clevotec/oobe/main/$_" -OutFile "$tempDir\$_"
}
& "$tempDir\business.ps1"
```

---

### 3. Developer Edition

**Purpose:** Comprehensive development workstation with full toolset

**Target Users:** Software developers, system administrators, IT professionals

**Packages Included:**

| Category | Packages |
|----------|----------|
| **Utilities** | 7-Zip, ADB, Git, Sysinternals, WinSCP, PowerToys |
| **Browsers** | Chrome, Brave, Firefox, Edge |
| **Communication** | Teams, Skype, Telegram, Thunderbird |
| **Office** | Microsoft Office, LibreOffice, Foxit Reader, Obsidian |
| **Development** | Windows Terminal, VS Code, Notepad++, TortoiseGit, scrcpy |
| **Creative** | GIMP, Inkscape |
| **Security** | KeePassXC, SyncTrayzor, Tailscale |
| **Media** | VLC, FFmpeg, yt-dlp, Tidal |

**Windows Features:**
- Hyper-V
- Windows Sandbox
- WSL with Ubuntu

**Direct Execution:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$tempDir = "$env:TEMP\oobe-setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
@('developer.ps1', 'common.ps1', 'packages.ps1') | ForEach-Object {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/clevotec/oobe/main/$_" -OutFile "$tempDir\$_"
}
& "$tempDir\developer.ps1"
```

---

### 4. Chocolatey Uninstaller (`uninstall-chocolatey.ps1`)

**Purpose:** Safely removes Chocolatey package manager while preserving an inventory backup and warning about portable applications.

**Target Users:** Users migrating from Chocolatey to winget

**Features:**
- Creates a backup inventory of all installed Chocolatey packages to Desktop
- Detects portable apps that live inside the Chocolatey folder and warns before deletion
- Cleans up environment variables (PATH, ChocolateyInstall, etc.)
- Removes Chocolatey from both User and System PATH using Registry
- Stops Chocolatey Agent service if running
- Interactive confirmation before deleting portable apps

**What It Does:**

| Phase | Action | Description |
|-------|--------|-------------|
| **Phase 1** | Data Backup | Exports list of installed packages to `choco_inventory_YYYYMMDD.txt` on Desktop |
| **Phase 2** | Portable Detection | Scans for .exe files inside Chocolatey's lib folder and warns about deletion |
| **Phase 3** | Environment Cleanup | Removes Chocolatey paths from User/System PATH and deletes environment variables |
| **Phase 4** | File Removal | Stops Chocolatey Agent and deletes the Chocolatey installation directory |

**Standalone Execution:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/clevotec/oobe/main/uninstall-chocolatey.ps1'))
```

**Note:** All setup scripts automatically detect and offer to migrate from Chocolatey.

---

## Common Features (All Profiles)

### Windows Settings
- **Disable Bing Search** in Start Menu
- **Disable Game Bar Tips**
- **Enable Dark Theme** for apps and system
- **Enable Windows Spotlight** for desktop and lock screen
- **Minimize Search Box** on taskbar (icon only)

### Automation
- **Automatic Updates:** Scheduled task runs daily at 4:00 AM to update all winget packages
- **Windows Updates:** Installs all available Windows updates using PSWindowsUpdate module
- **Chocolatey Migration:** Automatically detects and migrates from Chocolatey

### Security & Authentication
- **Windows Hello for Business:** Enabled and configured
- **KeePassXC Browser Integration:** Automatically configures browser extensions

### Cleanup
- Removes Personal Microsoft Teams app (conflicts with Teams for Work/School)

---

## Package Categories

All packages are organized in `packages.ps1` by category:

| Category | Available Packages |
|----------|-------------------|
| **Utilities** | 7-Zip, ADB, Git, Sysinternals, WinSCP, PowerToys |
| **Browsers** | Chrome, Brave, Firefox, Edge |
| **Communication** | Teams, Skype, Zoom, Telegram, Thunderbird |
| **Office & Productivity** | Microsoft Office, Foxit Reader, LibreOffice, Adobe Reader, Obsidian |
| **Development Tools** | Windows Terminal, VS Code, Notepad++, TortoiseGit, scrcpy |
| **Creative Tools** | GIMP, Inkscape, OBS Studio |
| **Media Tools** | VLC, FFmpeg, yt-dlp, Tidal |
| **Security & Sync** | KeePassXC, SyncTrayzor, Tailscale |
| **Hardware Support** | Jabra Direct |

---

## Customization

### Adding New Packages

Edit `packages.ps1` and add to the appropriate category:

```powershell
$script:PackageCategories = [ordered]@{
    "Utilities" = @(
        @{ Id = "7zip.7zip"; Name = "7-Zip"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Your.PackageId"; Name = "Your App Name"; Profiles = @("Developer") }
        # ...
    )
}
```

### Creating Custom Functions

Add new functions to `common.ps1`:

```powershell
function Install-MyCustomApp {
    # Your custom installation logic
}
```

### Modifying OneDrive Tenant

Update the TenantGUID in the profile script or pass it to `Set-OneDriveForBusiness`:

```powershell
Set-OneDriveForBusiness -TenantGUID 'your-tenant-guid-here'
```

---

## Troubleshooting

### Winget Not Found

```powershell
# Install App Installer from Microsoft Store
Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
```

### Script Execution Policy Error

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Package Installation Failures

```powershell
# Manually install failed package
winget install --id PackageId --source winget

# Reset winget sources
winget source reset --force
```

### Windows Features Require Pro/Enterprise

Hyper-V and Windows Sandbox require Windows 10/11 Pro or Enterprise. The scripts will gracefully skip these on Home editions.

---

## Migration from Chocolatey

These scripts automatically detect Chocolatey installations and offer to migrate:

1. **Backup:** Creates inventory of installed packages
2. **Detect:** Warns about portable apps that will be deleted
3. **Clean:** Removes Chocolatey paths and environment variables
4. **Delete:** Removes Chocolatey installation directory

### Why Winget?

- Native to Windows 10/11 (no third-party installation required)
- Official Microsoft package manager
- Better integration with Windows Update and Store
- More reliable package sources
- Improved security with signed packages

---

## Quick Reference

| Script | Use Case | Packages | Special Features |
|--------|----------|----------|------------------|
| `setup.ps1` | Interactive Setup | Custom | Profile selection, package picker, feature selection |
| `standard.ps1` | Office & Creative | 19 | OneDrive KFM, Media Tools, Creative Suite |
| `business.ps1` | Business Productivity | 10 | Minimal, Business-focused, Quick Setup |
| `developer.ps1` | Software Development | 34 | WSL, Hyper-V, Sandbox, Dev Tools |
| `uninstall-chocolatey.ps1` | Chocolatey Removal | N/A | Backup, Portable Detection, Clean Uninstall |

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

---

## License

This project is provided as-is for use in configuring Windows workstations.

---

## Credits

Maintained by clevotec

**Previous Version:** Chocolatey-based with Boxstarter
**Current Version:** Native PowerShell with winget and interactive setup

---

**Last Updated:** 2025-12-18
