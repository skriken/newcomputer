# Windows 11 Gaming Setup Script
# Optimizes a Windows 11 PC for gaming with relevant apps and performance settings

# First, ensure we're running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Script needs admin privileges. Please run as administrator."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Create log file
$logFile = "gaming_setup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $logFile

# Function for logging
function Write-Log {
    param($Message)
    Write-Host $Message
    $Message | Out-File -FilePath $logFile -Append
}

Write-Log "Starting Windows 11 Gaming Setup Script at $(Get-Date)"

# ==== PACKAGE MANAGERS CHECK ==== #
Write-Log "Checking package managers..."

# Check if winget is available
try {
    winget --version
    Write-Log "Winget is already installed."
} catch {
    Write-Log "Winget not detected. Installing App Installer from Microsoft Store..."
    $hasPackageManager = Get-AppPackage -Name Microsoft.DesktopAppInstaller
    if (!$hasPackageManager -or [Version]$hasPackageManager.Version -lt [Version]"1.16.0") {
        Write-Log "Installing winget from GitHub..."
        $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $releases = Invoke-RestMethod -Uri $releases_url
        $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith(".msixbundle") } | Select-Object -First 1
        
        $downloadUrl = $latestRelease.browser_download_url
        $downloadPath = "$env:TEMP\winget.msixbundle"
        
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
        Add-AppPackage -Path $downloadPath
        
        Write-Log "Winget installed successfully."
    }
}

# Check if Scoop is installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
    scoop bucket add extras
} else {
    Write-Log "Scoop is already installed."
}

# ==== INSTALLING GAMING APPLICATIONS ==== #
Write-Log "Installing gaming applications..."

# Array of applications to install
$applications = @(
    @{Name = "Discord"; Command = "winget install Discord.Discord" },
    @{Name = "Medal.tv"; Command = "winget install Medal.Medal" },
    @{Name = "Logitech G Hub"; Command = "winget install Logitech.GHUB" },
    @{Name = "Mobalytics"; Command = "winget install Mobalytics.Mobalytics" },
    @{Name = "Elgato Control Center"; Command = "winget install Elgato.ControlCenter" },
    @{Name = "Steam"; Command = "winget install Valve.Steam" },
    @{Name = "7-Zip"; Command = "winget install 7zip.7zip" },
    @{Name = "Epic Games Launcher"; Command = "winget install EpicGames.EpicGamesLauncher" },
    @{Name = "Malwarebytes"; Command = "winget install Malwarebytes.Malwarebytes" },
    @{Name = "HWiNFO"; Command = "winget install REALiX.HWiNFO" }
)

# Install each application
foreach ($app in $applications) {
    Write-Log "Installing $($app.Name)..."
    try {
        Invoke-Expression $app.Command
        Write-Log "$($app.Name) installed successfully."
    } catch {
        Write-Log "Error installing $($app.Name): $_"
    }
}

# Special installations
# DirectX Runtime
Write-Log "Installing DirectX Runtime..."
try {
    $directXUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
    $directXPath = "$env:TEMP\dxwebsetup.exe"
    Invoke-WebRequest -Uri $directXUrl -OutFile $directXPath
    Start-Process -FilePath $directXPath -ArgumentList "/Q" -Wait
    Write-Log "DirectX Runtime installed successfully."
} catch {
    Write-Log "Error installing DirectX Runtime: $_"
}

# Noedrive (assuming this is a custom or specific application)
Write-Log "Note: Please manually install Noedrive as it's not available through standard package managers."

# ==== CONFIGURING GAMING OPTIMIZATIONS ==== #
Write-Log "Optimizing Windows for gaming performance..."

# Create and set Ultimate Performance power plan
Write-Log "Setting up Ultimate Performance power plan..."
try {
    # Check if Ultimate Performance plan exists
    $ultimatePlan = powercfg /list | Select-String "Ultimate Performance"
    
    # If not, create it
    if (!$ultimatePlan) {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 88888888-8888-8888-8888-888888888888
        Write-Log "Created Ultimate Performance power plan."
    }
    
    # Set as active
    powercfg /setactive 88888888-8888-8888-8888-888888888888
} catch {
    # Fallback to High Performance if Ultimate Performance creation fails
    Write-Log "Falling back to High Performance power plan..."
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}

# Enable Game Mode
Write-Log "Enabling Game Mode..."
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f

# Optimize for performance rather than appearance
Write-Log "Optimizing visual effects for performance..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f

# Disable notifications during gaming
Write-Log "Disabling notifications during gaming..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOAST_NOTIFICATION" /t REG_DWORD /d 0 /f

# Disable fullscreen optimizations for games
Write-Log "Disabling fullscreen optimizations..."
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f

# Optimize network settings
Write-Log "Optimizing network settings for gaming..."
# Set network to metered to prevent background downloads
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d 2 /f
# Disable auto-tuning for network
netsh int tcp set global autotuninglevel=disabled
# Set optimal QoS settings
netsh int tcp set global ecncapability=disabled

# Optimize mouse settings for gaming
Write-Log "Optimizing mouse settings for gaming..."
# Disable mouse acceleration
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f

# Optimize GPU for performance
Write-Log "Optimizing GPU for performance..."
# Set preference to high performance NVIDIA GPU
if (Get-Command "nvidia-smi" -ErrorAction SilentlyContinue) {
    reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NvCache" /v "PrimaryPushBufferSize" /t REG_DWORD /d 1048576 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f
    Write-Log "NVIDIA GPU optimizations applied."
}

# Set processor scheduling to prefer programs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f

# Disable Windows Update during gaming
Write-Log "Configuring Windows Update to not interrupt gaming..."
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursStart" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursEnd" /t REG_DWORD /d 23 /f

# ==== ADDITIONAL GAMING TWEAKS ==== #
Write-Log "Applying additional gaming tweaks..."

# Disable Nagle's algorithm for reduced latency
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpNoDelay" /t REG_DWORD /d 1 /f

# Set high DPI scaling for games
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnablePerProcessSystemDPI" /t REG_DWORD /d 1 /f

# Game Bar settings
Write-Log "Configuring Game Bar..."
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d 3 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f

# Set Xbox Game DVR priority
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f

# ==== FINISHING UP ==== #
Write-Log "Gaming setup complete! A system restart is required for all changes to take effect."
Write-Log "Log file is saved at: $logFile"

# Prompt for restart
$restart = Read-Host "Would you like to restart now to apply all gaming optimizations? (y/n)"
if ($restart -eq "y") {
    Restart-Computer
}

Stop-Transcript
