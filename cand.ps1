## Boxstarter script https://boxstarter.org/package/url?https://raw.githubusercontent.com/clevotec/oobe/main/cand.ps1
# Boxstarter Winconfig
Disable-BingSearch
Disable-GameBarTips
Set-ExplorerOptions -showFileExtensions
Set-BoxstarterTaskbarOptions -DisableSearchBox

choco feature enable -n=useRememberedArgumentsForUpgrades

choco install 7zip
choco install googlechrome brave firefox
choco install microsoft-teams.install
choco install microsoft-edge
choco install office365business --params '/updates /eula'
choco install jabra-direct
choco install keepass keepass-rpc
choco install vlc ffmpeg yt-dlp
choco install gimp inkscape
choco install libreoffice-fresh
choco install microsoft-windows-terminal
choco install obs-studio
choco install tailscale
choco install skype
choco install foxitreader
choco install vscode notepadplusplus
choco install notepadreplacer --params='"/NOTEPAD:C:\Program Files\Notepad++\notepad++.exe"'
choco install choco-upgrade-all-at --params '/DAILY:yes /TIME:04:00 /ABORTTIME:08:00'
choco install chocolateygui choco-cleaner choco-upgrade-all-at-startup


# Onedrive Setup
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' ##Path to HKLM keys
$TenantGUID = '3db75043-219a-4c39-90e2-88cd1838fca4'

if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}

New-ItemProperty -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable silent account configuration
New-ItemProperty -Path $HKLMregistryPath -Name 'DisablePersonalSync' -Value '1' -PropertyType DWORD -Force | Out-Null ##Disable personal OneDrive
New-ItemProperty -Path $HKLMregistryPath -Name 'FilesonDemandEnabled' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable Files on Demand
New-ItemProperty -Path $HKLMregistryPath -Name 'KFMSilentOptIn' -Value $TenantGUID -PropertyType String -Force | Out-Null ##Enable KFM
New-ItemProperty -Path $HKLMregistryPath -Name 'KFMSilentOptInWithNotification' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable KFM with notification

# Windows Hello for Business
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' ##Path to HKLM keys
if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}
New-ItemProperty -Path $HKLMregistryPath -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable Windows Hello for Business
# New-ItemProperty -Path $HKLMregistryPath -Name 'DisablePostLogonProvisioning' -Value '1' -PropertyType DWORD -Force | Out-Null ##Disable post logon provisioning
# New-ItemProperty -Path $HKLMregistryPath -Name 'RequirePinForSignIn' -Value '1' -PropertyType DWORD -Force | Out-Null ##Require PIN for sign in
# New-ItemProperty -Path $HKLMregistryPath -Name 'UsePreferredBiometric' -Value '1' -PropertyType DWORD -Force | Out-Null ##Use preferred biometric

# Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\SearchScopes" -Name "ShowSearchSuggestionsGlobal" -Value 1

# Remove Personal Teams
If ($null -eq (Get-AppxPackage -Name MicrosoftTeams -AllUsers)) {
    Write-Output “Microsoft Teams Personal App not present”
}
Else {
    Try {
        Write-Output “Removing Microsoft Teams Personal App”
        Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppPackage -AllUsers
    }
    catch {
        Write-Output “Error removing Microsoft Teams Personal App”
    }
}


# Install Windows Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate