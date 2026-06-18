# Windows Privacy & Debloat - telemetry, ads, forced AI off + junk apps removed.
# Reversible. Touches nothing you installed. Run as admin.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host 'Run this in an admin PowerShell.' -ForegroundColor Red; return
}

function Reg($path,$name,$val){ if(-not(Test-Path $path)){New-Item $path -Force|Out-Null}; New-ItemProperty $path $name -Value $val -PropertyType DWord -Force|Out-Null }

Write-Host 'Telemetry / data collection' -ForegroundColor Cyan
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
foreach($s in 'DiagTrack','dmwappushservice'){ try{ Stop-Service $s -Force -ErrorAction SilentlyContinue; Set-Service $s -StartupType Disabled -ErrorAction Stop }catch{} }

Write-Host 'Advertising ID / tailored experiences / app tracking' -ForegroundColor Cyan
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' 0
Reg 'HKCU:\Control Panel\International\User Profile' 'HttpAcceptLanguageOptOut' 1
Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0

Write-Host 'Suggested content / ads / promo-app auto-install' -ForegroundColor Cyan
$cdm='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
'SilentInstalledAppsEnabled','SystemPaneSuggestionsEnabled','SoftLandingEnabled','RotatingLockScreenOverlayEnabled',
'PreInstalledAppsEnabled','OemPreInstalledAppsEnabled','SubscribedContent-310093Enabled','SubscribedContent-338388Enabled',
'SubscribedContent-338389Enabled','SubscribedContent-338393Enabled','SubscribedContent-353694Enabled',
'SubscribedContent-353696Enabled','SubscribedContent-88000326Enabled' | ForEach-Object { Reg $cdm $_ 0 }
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableConsumerAccountStateContent' 1

Write-Host 'Activity history' -ForegroundColor Cyan
foreach($n in 'EnableActivityFeed','PublishUserActivities','UploadUserActivities'){ Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' $n 0 }

Write-Host 'Copilot / Recall / Click to Do' -ForegroundColor Cyan
Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1
Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1

Write-Host 'Bing / Cortana in Start search' -ForegroundColor Cyan
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'CortanaConsent' 0
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb' 0
Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0

Write-Host 'Removing preinstalled junk apps' -ForegroundColor Cyan
# edit this list to taste
$junk = 'Microsoft.BingNews','Microsoft.BingWeather','Microsoft.MicrosoftSolitaireCollection','Clipchamp.Clipchamp',
        'Microsoft.GetHelp','Microsoft.WindowsFeedbackHub','Microsoft.People','Microsoft.WindowsMaps',
        'Microsoft.MicrosoftOfficeHub','Microsoft.OutlookForWindows','Microsoft.PowerAutomateDesktop',
        'Microsoft.Windows.DevHome','Microsoft.549981C3F5F10'
foreach($a in $junk){ Get-AppxPackage -Name $a -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; "  $a" }

Write-Host "`nDone. Sign out or reboot. Nothing you installed was touched." -ForegroundColor Green
