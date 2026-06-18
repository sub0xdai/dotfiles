#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows privacy debloat: removes telemetry, disables ad tracking, strips
    provisioned bloatware, and hardens privacy-related registry policies.
.DESCRIPTION
    Must be run as Administrator. Applies HKLM and service changes in the
    elevated context; HKCU changes are redirected to the actual interactive
    user's registry hive (not the elevation account). Produces a transcript
    log and a summary of errors/warnings at completion.
    Reboot after execution for all changes to take effect.
.NOTES
    Tested on Windows 11 23H2+. Some Copilot/AI keys are
    gated behind build 22631+ and silently skipped on older builds.
#>

# safety net, user detection, version gating
# =============================================================================

$ErrorActionPreference = 'Continue'
$ScriptStart = Get-Date

# Transcript logging for forensic trace
$TranscriptPath = Join-Path $env:TEMP ('windows-debloat-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
try { Start-Transcript -Path $TranscriptPath -Append -ErrorAction Stop } catch {
    Write-Warning "Could not start transcript: $_"
}

$Err    = [System.Collections.Generic.List[string]]::new()
$Warn   = [System.Collections.Generic.List[string]]::new()
$Ok     = 0
$Fail   = 0

# Resolve the actual interactive user SID so HKCU writes land in the right hive.
# When elevated, $env:USERNAME / HKCU: point to the elevation account, not the
# logged-in user. We walk the explorer.exe owner to find the real session user.
$ActualUserSID = $null
try {
    $actualUser = (Get-CimInstance -Class Win32_ComputerSystem).UserName
    if (-not $actualUser) {
        # Fallback: owner of the first interactive explorer.exe
        $explorer = Get-CimInstance -Class Win32_Process -Filter "Name='explorer.exe'" |
            Sort-Object SessionId | Select-Object -First 1
        if ($explorer) {
            $owner = Invoke-CimMethod -InputObject $explorer -MethodName GetOwner
            $actualUser = "$($owner.Domain)\$($owner.User)"
        }
    }
    if ($actualUser) {
        $ActualUserSID = (New-Object System.Security.Principal.NTAccount($actualUser)).
            Translate([System.Security.Principal.SecurityIdentifier]).Value
        Write-Host "Resolved interactive user SID: $ActualUserSID ($actualUser)" -ForegroundColor DarkGray
    } else {
        $Warn.Add("Could not resolve interactive user — HKCU keys will target elevation account")
    }
} catch {
    $Warn.Add("User SID resolution failed: $_ — HKCU keys target elevation account")
}

$WinBuild   = [Environment]::OSVersion.Version.Build
$IsWin11_23H2 = $WinBuild -ge 22631
Write-Host "Windows build: $WinBuild  |  Win11 23H2+ AI keys: $IsWin11_23H2" -ForegroundColor DarkGray

# backup current registry state (paths we will mutate)
# =============================================================================

Write-Host "`n=== Phase 1: Registry backup ===" -ForegroundColor Cyan
$BackupDir = Join-Path $env:TEMP ('reg-backup-{0:yyyyMMdd-HHmmss}' -f (Get-Date))
$null = New-Item -Path $BackupDir -ItemType Directory -Force
$pathsToBackup = @(
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\System',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search',
    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization'
)
if ($ActualUserSID) {
    $pathsToBackup += @(
        "$ActualUserSID\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
        "$ActualUserSID\Software\Microsoft\Windows\CurrentVersion\Privacy",
        "$ActualUserSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced",
        "$ActualUserSID\Control Panel\International\User Profile",
        "$ActualUserSID\Software\Microsoft\Siuf\Rules",
        "$ActualUserSID\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "$ActualUserSID\Software\Policies\Microsoft\Windows\WindowsCopilot",
        "$ActualUserSID\Software\Policies\Microsoft\Windows\WindowsAI",
        "$ActualUserSID\Software\Microsoft\Windows\CurrentVersion\Search"
    )
}

foreach ($p in $pathsToBackup) {
    $fileSafe = $p -replace '[\\:]', '_'
    $outFile = Join-Path $BackupDir "$fileSafe.reg"
    try {
        $exportArgs = @('export', $p, $outFile, '/y')
        $proc = Start-Process -FilePath 'reg.exe' -ArgumentList $exportArgs -Wait -NoNewWindow -PassThru
        if ($proc.ExitCode -ne 0) {
            $Warn.Add("reg export failed (code $($proc.ExitCode)) for: $p")
        }
    } catch {
        $Warn.Add("reg export exception for $p : $_")
    }
}
Write-Host "Backup saved to: $BackupDir" -ForegroundColor DarkGray

# remove provisioned & installed packages
# =============================================================================

Write-Host "`n=== Phase 2: Package removal ===" -ForegroundColor Cyan

# $JunkApps: exact PackageFamilyName substrings to evict.
# 'Microsoft.549981C3F5F10' is the Cortana stub app; hash may change across
# Windows updates — re-audit after each feature update.
$JunkApps = @(
    'Microsoft.BingNews',
    'Microsoft.BingWeather',
    'Microsoft.MicrosoftSolitaireCollection',
    'Clipchamp.Clipchamp',
    'Microsoft.GetHelp',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.People',
    'Microsoft.WindowsMaps',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.OutlookForWindows',
    'Microsoft.PowerAutomateDesktop',
    'Microsoft.Windows.DevHome',
    'Microsoft.549981C3F5F10'
)

# Remove provisioned packages (system image, affects future users)
Write-Host "Provisioned packages:" -ForegroundColor Yellow
$provPkgs = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
foreach ($App in $JunkApps) {
    $match = $provPkgs | Where-Object { $_.DisplayName -like "*$App*" }
    if (-not $match) { continue }
    try {
        $match | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
        Write-Host "  [OK] provisioned: $App" -ForegroundColor Green
        $Ok++
    } catch {
        Write-Host "  [FAIL] provisioned: $App — $_" -ForegroundColor Red
        $Err.Add("Provisioned removal failed for $App : $_")
        $Fail++
    }
}

# Remove installed packages (all users)
Write-Host "Installed packages (all users):" -ForegroundColor Yellow
$instPkgs = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue
foreach ($App in $JunkApps) {
    $match = $instPkgs | Where-Object { $_.Name -like "*$App*" }
    if (-not $match) { continue }
    try {
        $match | Remove-AppxPackage -AllUsers -ErrorAction Stop
        Write-Host "  [OK] installed: $App" -ForegroundColor Green
        $Ok++
    } catch {
        Write-Host "  [FAIL] installed: $App — $_" -ForegroundColor Red
        $Err.Add("Installed removal failed for $App : $_")
        $Fail++
    }
}

# registry policy writes
# =============================================================================

Write-Host "`n=== Phase 3: Registry policy ===" -ForegroundColor Cyan

# Helper: resolve HKCU paths to the actual user's hive when available.
function Resolve-RegPath([string]$Path) {
    if ($ActualUserSID -and $Path.StartsWith('HKCU:\', [StringComparison]::OrdinalIgnoreCase)) {
        $rest = $Path.Substring(5)
        return "Registry::HKEY_USERS\$ActualUserSID$rest"
    }
    return $Path
}

# Helper: write a single reg value, preserving existing type if not DWord.
function Write-RegValue([string]$Path, [string]$Name, $Value) {
    # Get-ItemProperty returns a PSObject even if the value is $null;
    # reading .$Name on $null would throw, so guard with -ne $null.
    $existingVal = (Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    $existingType = if ($null -ne $existingVal) { $existingVal.GetType().Name } else { $null }

    $typeMap = @{
        'Int32'  = 'DWord'
        'String' = 'String'
        'Int64'  = 'QWord'
    }

    # Default DWord; override if existing type is known and not DWord
    $propType = 'DWord'
    if ($existingType -and $typeMap.ContainsKey($existingType) -and $existingType -ne 'Int32') {
        $propType = $typeMap[$existingType]
    }

    $null = New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value `
        -PropertyType $propType -Force -ErrorAction Stop
}

# Core states — paths use HKCU:/HKLM:; HKCU is remapped above
$RegistryStates = [ordered]@{
    # --- HKLM: machine-wide telemetry & policy ---
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' = @{
        AllowTelemetry                   = 0
        DoNotShowFeedbackNotifications   = 1
    }
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' = @{
        AllowTelemetry                   = 0
    }
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' = @{
        DisableWindowsConsumerFeatures      = 1
        DisableConsumerAccountStateContent  = 1
    }
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' = @{
        EnableActivityFeed     = 0
        PublishUserActivities  = 0
        UploadUserActivities   = 0
    }
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' = @{
        DisableWebSearch      = 1
        ConnectedSearchUseWeb = 0
        AllowCortana          = 0
    }
    # Delivery Optimization — stop P2P update sharing
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' = @{
        DODownloadMode = 0
    }

    # --- HKCU: per-user telemetry & tracking ---
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' = @{
        Enabled = 0
    }
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' = @{
        TailoredExperiencesWithDiagnosticDataEnabled = 0
    }
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' = @{
        Start_TrackProgs        = 0
        Start_IrisRecommendations = 0
        ShowCopilotButton       = 0
    }
    'HKCU:\Control Panel\International\User Profile' = @{
        HttpAcceptLanguageOptOut = 1
    }
    'HKCU:\Software\Microsoft\Siuf\Rules' = @{
        NumberOfSIUFInPeriod = 0
    }
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' = @{
        SilentInstalledAppsEnabled       = 0
        SystemPaneSuggestionsEnabled     = 0
        SoftLandingEnabled               = 0
        RotatingLockScreenOverlayEnabled = 0
        PreInstalledAppsEnabled          = 0
        OemPreInstalledAppsEnabled       = 0
        'SubscribedContent-310093Enabled'  = 0
        'SubscribedContent-338388Enabled'  = 0
        'SubscribedContent-338389Enabled'  = 0
        'SubscribedContent-338393Enabled'  = 0
        'SubscribedContent-353694Enabled'  = 0
        'SubscribedContent-353696Enabled'  = 0
        'SubscribedContent-88000326Enabled' = 0
    }
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' = @{
        BingSearchEnabled = 0
        CortanaConsent    = 0
    }
}

# Copilot / AI keys — only apply on Windows 11 23H2+
if ($IsWin11_23H2) {
    $RegistryStates['HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'] = @{
        TurnOffWindowsCopilot = 1
    }
    $RegistryStates['HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'] = @{
        TurnOffWindowsCopilot = 1
    }
    $RegistryStates['HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'] = @{
        DisableAIDataAnalysis = 1
        DisableClickToDo      = 1
    }
    $RegistryStates['HKCU:\Software\Policies\Microsoft\Windows\WindowsAI'] = @{
        DisableAIDataAnalysis = 1
        DisableClickToDo      = 1
    }
} else {
    Write-Host "Skipping Copilot/WindowsAI keys (requires build ≥ 22631, current: $WinBuild)" -ForegroundColor DarkGray
}

foreach ($Path in $RegistryStates.Keys) {
    $realPath = Resolve-RegPath $Path
    try {
        if (-not (Test-Path -LiteralPath $realPath)) {
            $null = New-Item -Path $realPath -Force -ErrorAction Stop
        }
        $Properties = $RegistryStates[$Path]
        foreach ($Prop in $Properties.Keys) {
            Write-RegValue -Path $realPath -Name $Prop -Value $Properties[$Prop]
        }
        Write-Host "  [OK] $Path" -ForegroundColor Green
        $Ok++
    } catch {
        Write-Host "  [FAIL] $Path — $_" -ForegroundColor Red
        $Err.Add("Registry write failed for $Path : $_")
        $Fail++
    }
}

# services: stop + disable
# =============================================================================

Write-Host "`n=== Phase 4: Services ===" -ForegroundColor Cyan

$Services = @(
    'DiagTrack',              # Connected User Experiences and Telemetry
    'dmwappushservice',        # Device Management WAP Push
    'WSearchIdxPi',           # Windows Search Indexer (optional; comment to keep)
    'XblAuthManager',         # Xbox Live Auth Manager
    'XblGameSave',            # Xbox Live Game Save
    'XboxNetApiSvc'           # Xbox Live Networking
)

# DiagTrack dependency warning
$diagDeps = Get-Service -Name 'DiagTrack' -DependentServices -ErrorAction SilentlyContinue |
    Where-Object { $_.Status -eq 'Running' }
if ($diagDeps) {
    $Warn.Add(("DiagTrack has dependent services: " + ($diagDeps.Name -join ', ') +
        " — these may enter StopPending state"))
}

foreach ($svc in $Services) {
    try {
        $s = Get-Service -Name $svc -ErrorAction Stop
        if ($s.Status -ne 'Stopped') {
            Stop-Service -Name $svc -Force -ErrorAction Stop
        }
        Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
        Write-Host "  [OK] $svc" -ForegroundColor Green
        $Ok++
    } catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
        # Service not found on this SKU — not a failure
        Write-Host "  [SKIP] $svc (not present on this edition)" -ForegroundColor DarkGray
        $Warn.Add("$svc not found; skipped")
    } catch {
        Write-Host "  [FAIL] $svc — $_" -ForegroundColor Red
        $Err.Add("Service $svc : $_")
        $Fail++
    }
}

# scheduled tasks
# =============================================================================

Write-Host "`n=== Phase 5: Scheduled tasks ===" -ForegroundColor Cyan

$ScheduledTasks = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask'
)

foreach ($taskPath in $ScheduledTasks) {
    try {
        $taskFolder = (Split-Path $taskPath -Parent) + '\'
        Disable-ScheduledTask -TaskPath $taskFolder `
            -TaskName (Split-Path $taskPath -Leaf) -ErrorAction Stop
        Write-Host "  [OK] $taskPath" -ForegroundColor Green
        $Ok++
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Host "  [SKIP] $taskPath (not found)" -ForegroundColor DarkGray
    } catch {
        Write-Host "  [FAIL] $taskPath — $_" -ForegroundColor Red
        $Err.Add("Scheduled task $taskPath : $_")
        $Fail++
    }
}

# Summary
# =============================================================================

$Elapsed = (Get-Date) - $ScriptStart
Write-Host ("`n" + '=' * 60) -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host ('=' * 60) -ForegroundColor Cyan
Write-Host "  Succeeded : $Ok" -ForegroundColor Green
Write-Host "  Failed    : $Fail" -ForegroundColor $(if ($Fail -gt 0) { 'Red' } else { 'Green' })
Write-Host "  Warnings  : $($Warn.Count)" -ForegroundColor $(if ($Warn.Count -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "  Elapsed   : $($Elapsed.ToString('mm\:ss'))" -ForegroundColor DarkGray
Write-Host "  Transcript: $TranscriptPath" -ForegroundColor DarkGray
Write-Host "  Backup    : $BackupDir" -ForegroundColor DarkGray

if ($Warn.Count -gt 0) {
    Write-Host "`nWarnings:" -ForegroundColor Yellow
    $Warn | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Yellow }
}

if ($Err.Count -gt 0) {
    Write-Host "`nErrors:" -ForegroundColor Red
    $Err | ForEach-Object { Write-Host "  X $_" -ForegroundColor Red }
}

Write-Host "`nReboot recommended for all changes to take effect." -ForegroundColor Green

try { Stop-Transcript -ErrorAction SilentlyContinue } catch { }

# Non-zero exit on any failure so automation pipelines can detect it
if ($Fail -gt 0) { exit 1 } else { exit 0 }
