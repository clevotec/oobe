#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Interactive OOBE Setup Script
.DESCRIPTION
    Main wrapper script for Windows OOBE setup with interactive package selection.
    Allows choosing between predefined profiles or custom package selection.
.PARAMETER Profile
    Optional. Specify a profile to skip interactive selection: Standard, Business, Developer
.PARAMETER SkipChocolateyMigration
    Skip the Chocolatey detection and migration step
.PARAMETER SkipWindowsUpdates
    Skip Windows Updates installation
.EXAMPLE
    .\setup.ps1
    Runs interactive setup with profile and package selection
.EXAMPLE
    .\setup.ps1 -Profile Developer
    Runs Developer profile without interactive prompts
#>

param(
    [ValidateSet("Standard", "Business", "Developer", "Custom")]
    [string]$Profile,

    [switch]$SkipChocolateyMigration,
    [switch]$SkipWindowsUpdates
)

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load modules
. "$ScriptPath\common.ps1"
. "$ScriptPath\packages.ps1"

#region Menu Functions

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "       Windows OOBE Setup - Interactive Installer" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "       Powered by winget - Modern package management" -ForegroundColor Gray
    Write-Host ""
}

function Show-ProfileMenu {
    Write-Host "  Select a setup profile:" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Standard  - $($script:ProfileDescriptions['Standard'])" -ForegroundColor Yellow
    Write-Host "    [2] Business  - $($script:ProfileDescriptions['Business'])" -ForegroundColor Yellow
    Write-Host "    [3] Developer - $($script:ProfileDescriptions['Developer'])" -ForegroundColor Yellow
    Write-Host "    [4] Custom    - $($script:ProfileDescriptions['Custom'])" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    [Q] Quit" -ForegroundColor Gray
    Write-Host ""

    do {
        $choice = Read-Host "  Enter your choice (1-4 or Q)"
        switch ($choice.ToUpper()) {
            "1" { return "Standard" }
            "2" { return "Business" }
            "3" { return "Developer" }
            "4" { return "Custom" }
            "Q" { return $null }
            default { Write-Host "  Invalid choice. Please try again." -ForegroundColor Red }
        }
    } while ($true)
}

function Show-PackageSelectionMenu {
    $allPackages = Get-AllPackages
    $selectedPackages = @{}

    # Initialize all as unselected
    foreach ($pkg in $allPackages) {
        $selectedPackages[$pkg.Id] = $false
    }

    $categories = $script:PackageCategories.Keys | ForEach-Object { $_ }
    $currentCategory = 0
    $redraw = $true

    while ($true) {
        if ($redraw) {
            Clear-Host
            Write-Host ""
            Write-Host "  ================================================================" -ForegroundColor Cyan
            Write-Host "       Custom Package Selection" -ForegroundColor Cyan
            Write-Host "  ================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Category: $($categories[$currentCategory])" -ForegroundColor Yellow
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Gray
            Write-Host ""

            $categoryPackages = $script:PackageCategories[$categories[$currentCategory]]
            $index = 1
            foreach ($pkg in $categoryPackages) {
                $marker = if ($selectedPackages[$pkg.Id]) { "[X]" } else { "[ ]" }
                $color = if ($selectedPackages[$pkg.Id]) { "Green" } else { "White" }
                Write-Host "    $marker [$index] $($pkg.Name)" -ForegroundColor $color
                $index++
            }

            Write-Host ""
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Gray
            Write-Host "  Commands:" -ForegroundColor Gray
            Write-Host "    [1-9]     Toggle package    [A] Select all in category" -ForegroundColor Gray
            Write-Host "    [N] Next category           [P] Previous category" -ForegroundColor Gray
            Write-Host "    [S] Select all packages     [C] Clear all selections" -ForegroundColor Gray
            Write-Host "    [D] Done with selection     [Q] Quit without saving" -ForegroundColor Gray
            Write-Host ""

            $selectedCount = ($selectedPackages.Values | Where-Object { $_ }).Count
            Write-Host "  Selected: $selectedCount packages" -ForegroundColor Cyan
            Write-Host ""
            $redraw = $false
        }

        $key = Read-Host "  Enter command"

        switch ($key.ToUpper()) {
            "N" {
                $currentCategory = ($currentCategory + 1) % $categories.Count
                $redraw = $true
            }
            "P" {
                $currentCategory = ($currentCategory - 1 + $categories.Count) % $categories.Count
                $redraw = $true
            }
            "A" {
                $categoryPackages = $script:PackageCategories[$categories[$currentCategory]]
                foreach ($pkg in $categoryPackages) {
                    $selectedPackages[$pkg.Id] = $true
                }
                $redraw = $true
            }
            "S" {
                foreach ($key in $selectedPackages.Keys) {
                    $selectedPackages[$key] = $true
                }
                $redraw = $true
            }
            "C" {
                foreach ($key in $selectedPackages.Keys) {
                    $selectedPackages[$key] = $false
                }
                $redraw = $true
            }
            "D" {
                $result = @()
                foreach ($pkg in $allPackages) {
                    if ($selectedPackages[$pkg.Id]) {
                        $result += $pkg
                    }
                }
                return $result
            }
            "Q" {
                return $null
            }
            default {
                if ($key -match '^\d+$') {
                    $num = [int]$key
                    $categoryPackages = $script:PackageCategories[$categories[$currentCategory]]
                    if ($num -ge 1 -and $num -le $categoryPackages.Count) {
                        $pkg = $categoryPackages[$num - 1]
                        $selectedPackages[$pkg.Id] = -not $selectedPackages[$pkg.Id]
                        $redraw = $true
                    }
                }
            }
        }
    }
}

function Show-WindowsFeaturesMenu {
    Write-Host ""
    Write-Host "  Optional Windows Features:" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Hyper-V         - Hardware virtualization platform" -ForegroundColor Yellow
    Write-Host "    [2] Windows Sandbox - Isolated desktop environment" -ForegroundColor Yellow
    Write-Host "    [3] WSL + Ubuntu    - Windows Subsystem for Linux" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    [A] Install all     [N] Skip all" -ForegroundColor Gray
    Write-Host ""

    $features = @{
        HyperV = $false
        Sandbox = $false
        WSL = $false
    }

    do {
        $choice = Read-Host "  Enter choices (e.g., 1,2,3 or A or N)"

        if ($choice.ToUpper() -eq "A") {
            $features.HyperV = $true
            $features.Sandbox = $true
            $features.WSL = $true
            return $features
        }
        elseif ($choice.ToUpper() -eq "N") {
            return $features
        }
        else {
            $selections = $choice -split ',' | ForEach-Object { $_.Trim() }
            foreach ($sel in $selections) {
                switch ($sel) {
                    "1" { $features.HyperV = $true }
                    "2" { $features.Sandbox = $true }
                    "3" { $features.WSL = $true }
                }
            }
            if ($features.HyperV -or $features.Sandbox -or $features.WSL -or $choice -eq "") {
                return $features
            }
            Write-Host "  Invalid choice. Please try again." -ForegroundColor Red
        }
    } while ($true)
}

function Show-ConfirmationMenu {
    param(
        [string]$ProfileName,
        [array]$Packages,
        [hashtable]$Features
    )

    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "       Installation Summary" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Profile: $ProfileName" -ForegroundColor Yellow
    Write-Host "  Packages to install: $($Packages.Count)" -ForegroundColor White
    Write-Host ""

    # Group packages by category for display
    $grouped = $Packages | Group-Object { $_.Category } | Sort-Object Name

    foreach ($group in $grouped) {
        Write-Host "    $($group.Name):" -ForegroundColor Cyan
        foreach ($pkg in $group.Group) {
            Write-Host "      - $($pkg.Name)" -ForegroundColor Gray
        }
    }

    if ($Features) {
        Write-Host ""
        Write-Host "  Windows Features:" -ForegroundColor Yellow
        if ($Features.HyperV) { Write-Host "      - Hyper-V" -ForegroundColor Gray }
        if ($Features.Sandbox) { Write-Host "      - Windows Sandbox" -ForegroundColor Gray }
        if ($Features.WSL) { Write-Host "      - WSL + Ubuntu" -ForegroundColor Gray }
        if (-not ($Features.HyperV -or $Features.Sandbox -or $Features.WSL)) {
            Write-Host "      (none selected)" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host ""

    $confirm = Read-Host "  Proceed with installation? (Y/N)"
    return $confirm.ToUpper() -eq "Y"
}

#endregion

#region Main Execution

function Start-OOBESetup {
    param(
        [string]$SelectedProfile,
        [array]$SelectedPackages,
        [hashtable]$SelectedFeatures
    )

    Write-Host ""
    Write-Host "=== Starting OOBE Setup ===" -ForegroundColor Cyan
    Write-Host "Profile: $SelectedProfile" -ForegroundColor Green
    Write-Host ""

    # Step 1: Chocolatey Migration
    if (-not $SkipChocolateyMigration) {
        Invoke-ChocolateyMigration
    }

    # Step 2: Verify Winget
    if (-not (Test-WingetAvailable)) {
        Write-Error "Cannot proceed without winget. Exiting."
        return
    }

    # Step 3: Windows Configuration
    Set-CommonWindowsSettings

    # Configure file explorer based on profile
    switch ($SelectedProfile) {
        "Developer" {
            Set-FileExplorerSettings -ShowFileExtensions $true -ShowHiddenFiles $true
            Enable-RemoteDesktop
        }
        "Business" {
            Set-FileExplorerSettings -ShowFileExtensions $false -ShowHiddenFiles $false
        }
        default {
            Set-FileExplorerSettings -ShowFileExtensions $true -ShowHiddenFiles $false
        }
    }

    # Step 4: Install Packages
    Write-Host "`n=== Installing Packages ===" -ForegroundColor Cyan

    $successful = 0
    $failed = 0

    foreach ($pkg in $SelectedPackages) {
        $source = if ($pkg.Source) { $pkg.Source } else { "winget" }
        if (Install-WingetPackage -PackageId $pkg.Id -Name $pkg.Name -Source $source) {
            $successful++
        }
        else {
            $failed++
        }
    }

    Write-Host "`n  Package installation complete: $successful succeeded, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })

    # Step 5: Windows Features (if selected)
    if ($SelectedFeatures) {
        Write-Host "`n=== Installing Windows Features ===" -ForegroundColor Cyan

        if ($SelectedFeatures.HyperV) {
            Install-WindowsFeature -FeatureName "Microsoft-Hyper-V-All" -DisplayName "Hyper-V"
        }
        if ($SelectedFeatures.Sandbox) {
            Install-WindowsFeature -FeatureName "Containers-DisposableClientVM" -DisplayName "Windows Sandbox"
        }
        if ($SelectedFeatures.WSL) {
            Install-WSL
        }
    }

    # Step 6: OneDrive Configuration (for Standard and Business)
    if ($SelectedProfile -eq "Standard") {
        Set-OneDriveForBusiness -TenantGUID '3db75043-219a-4c39-90e2-88cd1838fca4'
    }
    elseif ($SelectedProfile -eq "Business") {
        Set-OneDriveForBusiness -TenantGUID 'd911a68a-30cf-4719-80e6-dab4d56bfc93'
    }

    # Step 7: Windows Hello
    if ($SelectedProfile -eq "Business") {
        Enable-WindowsHelloForBusiness -DisablePostLogonProvisioning $true
    }
    else {
        Enable-WindowsHelloForBusiness
    }

    # Step 8: Post-Installation Configuration
    Write-Host "`n=== Post-Installation Configuration ===" -ForegroundColor Cyan

    Set-NotepadPlusPlusAsDefault

    # Configure KeePassXC extensions based on installed browsers
    $hasChrome = $SelectedPackages | Where-Object { $_.Id -eq "Google.Chrome" }
    $hasEdge = $SelectedPackages | Where-Object { $_.Id -eq "Microsoft.Edge" }
    $hasBrave = $SelectedPackages | Where-Object { $_.Id -eq "Brave.Brave" }

    if ($hasChrome -or $hasEdge -or $hasBrave) {
        Set-KeePassXCBrowserExtensions -Chrome ([bool]$hasChrome) -Edge ([bool]$hasEdge) -Brave ([bool]$hasBrave)
    }

    Remove-PersonalTeamsApp
    Register-WingetAutoUpdate

    # Step 9: Windows Updates
    if (-not $SkipWindowsUpdates) {
        Install-WindowsUpdates
    }

    Write-Host "`n=== OOBE Setup Complete! ===" -ForegroundColor Green
    Write-Host "A restart may be required to complete installation of some features." -ForegroundColor Yellow
    Write-Host ""
}

#endregion

#region Entry Point

# If profile specified via parameter, run non-interactively
if ($Profile -and $Profile -ne "Custom") {
    $packages = Get-PackagesForProfile -Profile $Profile
    $features = @{ HyperV = $false; Sandbox = $false; WSL = $false }

    if ($Profile -eq "Developer") {
        $features = @{ HyperV = $true; Sandbox = $true; WSL = $true }
    }

    # Add category info to packages
    $packagesWithCategory = @()
    foreach ($pkg in $packages) {
        foreach ($category in $script:PackageCategories.Keys) {
            $found = $script:PackageCategories[$category] | Where-Object { $_.Id -eq $pkg.Id }
            if ($found) {
                $packagesWithCategory += @{
                    Id = $pkg.Id
                    Name = $pkg.Name
                    Category = $category
                    Source = if ($pkg.Source) { $pkg.Source } else { "winget" }
                }
                break
            }
        }
    }

    Start-OOBESetup -SelectedProfile $Profile -SelectedPackages $packagesWithCategory -SelectedFeatures $features
    exit 0
}

# Interactive mode
Show-Banner

$selectedProfile = Show-ProfileMenu

if (-not $selectedProfile) {
    Write-Host "  Setup cancelled." -ForegroundColor Yellow
    exit 0
}

$selectedPackages = @()
$selectedFeatures = @{ HyperV = $false; Sandbox = $false; WSL = $false }

if ($selectedProfile -eq "Custom") {
    $selectedPackages = Show-PackageSelectionMenu

    if (-not $selectedPackages) {
        Write-Host "  Setup cancelled." -ForegroundColor Yellow
        exit 0
    }

    $selectedFeatures = Show-WindowsFeaturesMenu
}
else {
    $packages = Get-PackagesForProfile -Profile $selectedProfile

    # Add category info to packages
    foreach ($pkg in $packages) {
        foreach ($category in $script:PackageCategories.Keys) {
            $found = $script:PackageCategories[$category] | Where-Object { $_.Id -eq $pkg.Id }
            if ($found) {
                $selectedPackages += @{
                    Id = $pkg.Id
                    Name = $pkg.Name
                    Category = $category
                    Source = if ($pkg.Source) { $pkg.Source } else { "winget" }
                }
                break
            }
        }
    }

    if ($selectedProfile -eq "Developer") {
        $selectedFeatures = @{ HyperV = $true; Sandbox = $true; WSL = $true }
    }
}

# Show confirmation
if (-not (Show-ConfirmationMenu -ProfileName $selectedProfile -Packages $selectedPackages -Features $selectedFeatures)) {
    Write-Host "  Setup cancelled." -ForegroundColor Yellow
    exit 0
}

# Run the setup
Start-OOBESetup -SelectedProfile $selectedProfile -SelectedPackages $selectedPackages -SelectedFeatures $selectedFeatures

#endregion
