# Boxstarter Winconfig
Disable-BingSearch
Disable-GameBarTips
Set-ExplorerOptions -showFileExtensions -showHiddenFilesAndFolders
Set-BoxstarterTaskbarOptions -DisableSearchBox

# Enable Remote Desktop
Enable-RemoteDesktop
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

choco feature enable -n=useRememberedArgumentsForUpgrades

choco install 7zip
choco install adb
choco install brave
choco install ffmpeg
choco install firefox
choco install gimp
choco install git
choco install googlechrome
choco install inkscape
choco install keepass
choco install keepass-rpc
choco install keepass-plugin-keetraytotp
choco install libreoffice-fresh
choco install microsoft-edge
choco install microsoft-office-deployment --params '/64bit /Product:ProPlus2021Volume'
choco install microsoft-windows-terminal
choco install micrsoft-teams.install
choco install notepadplusplus
choco install notepadreplacer --params='"/NOTEPAD:C:\Program Files\Notepad++\notepad++.exe"'
choco install obsidian
choco install powertoys
choco install skype
choco install scrcpy
choco install foxitreader
choco install synctrayzor
choco install sysinternals
choco install tailscale
choco install telegram.install
choco install thunderbird
choco install tidal
choco install tortoisegit
choco install vlc
choco install vscode
choco install winscp
choco install yt-dlp
choco install choco-upgrade-all-at --params '/DAILY:yes /TIME:04:00 /ABORTTIME:08:00'
choco install chocolateygui choco-cleaner choco-upgrade-all-at-startup


choco install Microsoft-Hyper-V-All -source windowsFeatures
$hypervState = (Get-WindowsOptionalFeature -Featurename "Microsoft-Hyper-V-All" -Online)
if (!$hypervState) {
    Write-Warning "Unsupported Operating System: Windows 10 Pro or Enterprise 1903 or greater required."
    throw
}
if ($hypervState.state -eq 'Enabled') {
    Write-Host "  ** Hyper-V-All already installed!" -Foreground Magenta
    return
}
else {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart
}

# Install Windows Sandbox
$sandboxState = (Get-WindowsOptionalFeature -Featurename "Containers-DisposableClientVM" -Online)
if (!$sandboxState) {
    Write-Warning "Unsupported Operating System: Windows 10 Pro or Enterprise 1903 or greater required."
    throw
}
if ($sandboxState.state -eq 'Enabled') {
    Write-Host "  ** Sandbox already installed!" -Foreground Magenta
    return
}
else {
    Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -NoRestart
}

# Setup WSL
choco install Microsoft-Windows-Subsystem-Linux -source windowsFeatures
choco install npiperelay
& wsl.exe --install -d Ubuntu

if ( -not ( get-command Install-ChocolateyPackage -erroraction silentlycontinue ) ) {
    Write-Host "Importing chocolateyInstaller.psm1..."
    Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1 #-Verbose
}
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\Firefox\firefox.exe"
# Install-ChocolateyPinnedTaskBarItem "$sublimeDir\sublime_text.exe"
# Install-ChocolateyFileAssociation ".txt" "$env:programfiles\Sublime Text 2\sublime_text.exe"
# Install-ChocolateyFileAssociation ".md" "$env:programfiles\Sublime Text 2\sublime_text.exe"

#choco install IIS-WebServerRole -source windowsfeatures

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
Install-WindowsUpdate -AcceptEula
