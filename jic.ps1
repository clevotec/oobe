#Set-ExplorerOptions -showFileExtensions
#Enable-RemoteDesktop

choco install 7zip
choco install googlechrome
choco install microsoft-office-deployment --params '/64bit /Product:ProPlus2021Volume'
choco install brave
choco install adobereader
choco install microsoft-edge
choco install keepass
choco install keepass-rpc
choco install vlc
choco install choco-upgrade-all-at --params '/DAILY:yes /TIME:04:00 /ABORTTIME:08:00'

#choco install Microsoft-Hyper-V-All -source windowsFeatures
#choco install IIS-WebServerRole -source windowsfeatures
