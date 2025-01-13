## == INSTRUCTIONS == ##
# 1. Open CMD as admin
# 2. Run this: powershell -ExecutionPolicy Bypass -NoExit -File gaming_setup.ps1
# 3. You're done!

## == INITIAL SETUP == ##

# First, ensure we're running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Script needs admin privileges. Please run as administrator."
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

# Check if winget is available
try {
    winget --version
} catch {
    Write-Log "Winget is required. Please ensure you have App Installer installed from the Microsoft Store."
    exit
}

## == INSTALLING GAMING APPS == ##
Write-Log "Beginning gaming software installation..."

# Discord
winget install Discord.Discord

# Medal.tv
winget install Medal.Medal

# Logitech G Hub
winget install Logitech.GHUB

# OneDrive
winget install Microsoft.OneDrive

# Mobalytics
winget install Mobalytics.GG

# Elgato Control Center
winget install Elgato.ControlCenter

# GeForce Now
winget install Nvidia.GeForceNow

# Steam
winget install Valve.Steam

# 7-Zip
winget install 7zip.7zip

# Epic Games Launcher
winget install EpicGames.EpicGamesLauncher

# Malwarebytes
winget install Malwarebytes.Malwarebytes

# DirectX Runtime
winget install -e --id Microsoft.DirectX

# Visual C++ Redistributables (required by many games)
winget install -e --id Microsoft.VCRedist.2015+.x64
winget install -e --id Microsoft.VCRedist.2015+.x86

# Xbox App (for Game Pass)
winget install -e --id Microsoft.XboxApp

# HWiNFO (for system monitoring)
winget install -e --id REALiX.HWiNFO

## == SETTING UP WINDOWS SETTINGS == ##

# Windows Settings Section
Write-Log "Configuring Windows settings..."

# Performance settings - High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Dark theme
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f

# Game Mode
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f

# Disable sticky keys prompt
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d "506" /f

# Disable Windows notifications during games
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\NotificationSettings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATIONS_ABOVE_LOCK" /t REG_DWORD /d 0 /f

# Optimize for performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f

# Additional Windows Optimizations
Write-Log "Applying additional gaming optimizations..."

# Disable Full-Screen Optimizations globally
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f

# Disable Xbox Game DVR and Game Bar
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f

# Enable Hardware-Accelerated GPU Scheduling (Windows 10 2004 or later)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f

# Set High Performance in Graphics Settings
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "VRROptimizeEnable=0;SwapEffectUpgradeEnable=0;HwSchMode=2" /f

# Disable Power Throttling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f

# Set High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable Nagle's Algorithm for lower latency
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*" /v "TCPNoDelay" /t REG_DWORD /d "1" /f

# Network Optimization
# Set network adapter power management
Write-Log "Optimizing network settings..."
Get-NetAdapter | ForEach-Object {
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Power Saving Mode" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
}

Write-Log "Gaming setup complete. Please restart your computer for all changes to take effect."

Stop-Transcript
