<#
.SYNOPSIS
    Package definitions for OOBE Setup Scripts
.DESCRIPTION
    Contains all package definitions organized by category.
    Used by setup.ps1 and individual edition scripts.
#>

# Package Categories and Definitions
$script:PackageCategories = [ordered]@{
    "Utilities" = @(
        @{ Id = "7zip.7zip"; Name = "7-Zip"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Google.PlatformTools"; Name = "Android Debug Bridge (ADB)"; Profiles = @("Developer") }
        @{ Id = "Git.Git"; Name = "Git"; Profiles = @("Developer") }
        @{ Id = "Microsoft.Sysinternals.Suite"; Name = "Sysinternals Suite"; Profiles = @("Developer") }
        @{ Id = "WinSCP.WinSCP"; Name = "WinSCP"; Profiles = @("Developer") }
        @{ Id = "Microsoft.PowerToys"; Name = "PowerToys"; Profiles = @("Developer") }
    )

    "Browsers" = @(
        @{ Id = "Google.Chrome"; Name = "Google Chrome"; Profiles = @("Standard", "Developer") }
        @{ Id = "Brave.Brave"; Name = "Brave Browser"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Mozilla.Firefox"; Name = "Mozilla Firefox"; Profiles = @("Standard", "Developer") }
        @{ Id = "Microsoft.Edge"; Name = "Microsoft Edge"; Profiles = @("Standard", "Business", "Developer") }
    )

    "Communication" = @(
        @{ Id = "Microsoft.Teams"; Name = "Microsoft Teams"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Microsoft.Skype"; Name = "Skype"; Profiles = @("Standard", "Developer") }
        @{ Id = "Zoom.Zoom"; Name = "Zoom"; Profiles = @("Business") }
        @{ Id = "Telegram.TelegramDesktop"; Name = "Telegram"; Profiles = @("Developer") }
        @{ Id = "Mozilla.Thunderbird"; Name = "Thunderbird"; Profiles = @("Developer") }
    )

    "Office & Productivity" = @(
        @{ Id = "Microsoft.Office"; Name = "Microsoft Office"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Foxit.FoxitReader"; Name = "Foxit PDF Reader"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "TheDocumentFoundation.LibreOffice"; Name = "LibreOffice"; Profiles = @("Standard", "Developer") }
        @{ Id = "Adobe.Acrobat.Reader.64-bit"; Name = "Adobe Acrobat Reader"; Profiles = @("Business") }
        @{ Id = "Obsidian.Obsidian"; Name = "Obsidian"; Profiles = @("Developer") }
    )

    "Development Tools" = @(
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal"; Profiles = @("Standard", "Developer") }
        @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code"; Profiles = @("Standard", "Developer") }
        @{ Id = "Notepad++.Notepad++"; Name = "Notepad++"; Profiles = @("Standard", "Developer") }
        @{ Id = "TortoiseGit.TortoiseGit"; Name = "TortoiseGit"; Profiles = @("Developer") }
        @{ Id = "Genymobile.scrcpy"; Name = "scrcpy"; Profiles = @("Developer") }
    )

    "Creative Tools" = @(
        @{ Id = "GIMP.GIMP"; Name = "GIMP"; Profiles = @("Standard", "Developer") }
        @{ Id = "Inkscape.Inkscape"; Name = "Inkscape"; Profiles = @("Standard", "Developer") }
        @{ Id = "OBSProject.OBSStudio"; Name = "OBS Studio"; Profiles = @("Standard") }
    )

    "Media Tools" = @(
        @{ Id = "VideoLAN.VLC"; Name = "VLC Media Player"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "Gyan.FFmpeg"; Name = "FFmpeg"; Profiles = @("Standard", "Developer") }
        @{ Id = "yt-dlp.yt-dlp"; Name = "yt-dlp"; Profiles = @("Standard", "Developer") }
        @{ Id = "9NBLGGH6X7MR"; Name = "Tidal"; Source = "msstore"; Profiles = @("Developer") }
    )

    "Security & Sync" = @(
        @{ Id = "KeePassXCTeam.KeePassXC"; Name = "KeePassXC"; Profiles = @("Standard", "Business", "Developer") }
        @{ Id = "SyncTrayzor.SyncTrayzor"; Name = "SyncTrayzor"; Profiles = @("Developer") }
        @{ Id = "tailscale.tailscale"; Name = "Tailscale"; Profiles = @("Standard", "Developer") }
    )

    "Hardware Support" = @(
        @{ Id = "Jabra.Direct"; Name = "Jabra Direct"; Profiles = @("Standard") }
    )
}

# Windows Features (Developer only)
$script:WindowsFeatures = @(
    @{ Name = "Microsoft-Hyper-V-All"; DisplayName = "Hyper-V"; Profiles = @("Developer") }
    @{ Name = "Containers-DisposableClientVM"; DisplayName = "Windows Sandbox"; Profiles = @("Developer") }
    @{ Name = "Microsoft-Windows-Subsystem-Linux"; DisplayName = "WSL"; Profiles = @("Developer") }
)

# Profile Descriptions
$script:ProfileDescriptions = @{
    "Standard"  = "General office and creative workstation (19 packages)"
    "Business"  = "Streamlined business productivity (10 packages)"
    "Developer" = "Full development environment with WSL, Hyper-V (34 packages)"
    "Custom"    = "Select individual packages interactively"
}

function Get-PackagesForProfile {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Standard", "Business", "Developer")]
        [string]$Profile
    )

    $packages = @()
    foreach ($category in $script:PackageCategories.Keys) {
        foreach ($pkg in $script:PackageCategories[$category]) {
            if ($pkg.Profiles -contains $Profile) {
                $packages += $pkg
            }
        }
    }
    return $packages
}

function Get-AllPackages {
    $packages = @()
    foreach ($category in $script:PackageCategories.Keys) {
        foreach ($pkg in $script:PackageCategories[$category]) {
            $packages += @{
                Id = $pkg.Id
                Name = $pkg.Name
                Category = $category
                Source = if ($pkg.Source) { $pkg.Source } else { "winget" }
                Profiles = $pkg.Profiles
            }
        }
    }
    return $packages
}

function Get-WindowsFeaturesForProfile {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Standard", "Business", "Developer")]
        [string]$Profile
    )

    return $script:WindowsFeatures | Where-Object { $_.Profiles -contains $Profile }
}
