# Boxstarter Winconfig
Disable-BingSearch
Disable-GameBarTips
Set-ExplorerOptions -showFileExtensions 
Set-BoxstarterTaskbarOptions -DisableSearchBox

choco feature enable -n=useRememberedArgumentsForUpgrades

choco install 7zip
choco install brave
choco install firefox
choco install gimp
choco install googlechrome
choco install inkscape
choco install keepass
choco install keepass-rpc
choco install keepass-plugin-keetraytotp
choco install microsoft-edge
choco install microsoft-office-deployment --params '/64bit /Product:ProPlus2021Volume'
choco install microsoft-windows-terminal
choco install notepadplusplus
choco install notepadreplacer --params='"/NOTEPAD:C:\Program Files\Notepad++\notepad++.exe"'
choco install obsidian
choco install skype
choco install foxitreader
choco install telegram.install
choco install tidal
choco install vlc
choco install choco-upgrade-all-at --params '/DAILY:yes /TIME:04:00 /ABORTTIME:08:00'
choco install chocolateygui choco-cleaner choco-upgrade-all-at-startup


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
