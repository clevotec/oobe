# Boxstarter Winconfig
Disable-BingSearch
Disable-GameBarTips
Set-ExplorerOptions -hideFileExtensions -hideHiddenFilesAndFolders
Set-BoxstarterTaskbarOptions -DisableSearchBox

choco install -y 7zip
choco install -y googlechrome
choco install -y microsoft-office-deployment --params '/64bit /Product:ProPlus2021Volume'
choco install -y brave
choco install -y adobereader
choco install -y microsoft-edge
choco install -y keepass
choco install -y keepass-rpc
choco install -y vlc
choco install -y choco-upgrade-all-at --params '/DAILY:yes /TIME:04:00 /ABORTTIME:08:00'
choco install -y micrsoft-teams.install

# Onedrive Setup
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' ##Path to HKLM keys
$TenantGUID = 'd911a68a-30cf-4719-80e6-dab4d56bfc93'

if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}

New-ItemProperty -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable silent account configuration
New-ItemProperty -Path $HKLMregistryPath -Name 'DisablePersonalSync' -Value '1' -PropertyType DWORD -Force | Out-Null ##Disable personal OneDrive
New-ItemProperty -Path $HKLMregistryPath -Name 'FilesonDemandEnabled' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable Files on Demand
New-ItemProperty -Path $HKLMregistryPath -Name 'KFMSilentOptInWithNotification' -Value $TenantGUID -PropertyType String -Force | Out-Null ##Enable KFM with notification


# Windows Hello for Business
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' ##Path to HKLM keys
if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}
New-ItemProperty -Path $HKLMregistryPath -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable Windows Hello for Business
New-ItemProperty -Path $HKLMregistryPath -Name 'DisablePostLogonProvisioning' -Value '1' -PropertyType DWORD -Force | Out-Null ##Disable post logon provisioning
# New-ItemProperty -Path $HKLMregistryPath -Name 'RequirePinForSignIn' -Value '1' -PropertyType DWORD -Force | Out-Null ##Require PIN for sign in
# New-ItemProperty -Path $HKLMregistryPath -Name 'UsePreferredBiometric' -Value '1' -PropertyType DWORD -Force | Out-Null ##Use preferred biometric

# Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\SearchScopes" -Name "ShowSearchSuggestionsGlobal" -Value 1


# Install Windows Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula