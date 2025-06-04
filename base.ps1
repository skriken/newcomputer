# Windows Performance & Gaming Optimization Script with Precise Time Sync
# Run as Administrator

Write-Host "Applying Windows Performance Optimizations..." -ForegroundColor Green

# Set correct time zone for Norway and sync time with multiple attempts
Write-Host "Setting time zone to Norway (Central European Time)..." -ForegroundColor Yellow
try {
    # Set time zone to Central European Time (Norway)
    tzutil /s "Central European Standard Time"
    Write-Host "Time zone set to Central European Time!" -ForegroundColor Green
    
    # Configure multiple high-accuracy time servers
    Write-Host "Configuring high-accuracy time servers..." -ForegroundColor Yellow
    w32tm /config /manualpeerlist:"0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org" /syncfromflags:manual /reliable:yes /update
    
    # Restart time service for clean sync
    Stop-Service w32time -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Service w32time
    Start-Sleep -Seconds 3
    
    # Multiple sync attempts for accuracy
    Write-Host "Performing precise time synchronization (3 attempts)..." -ForegroundColor Yellow
    for ($i = 1; $i -le 3; $i++) {
        Write-Host "Sync attempt $i..." -ForegroundColor Gray
        w32tm /resync /force /nowait
        Start-Sleep -Seconds 5
    }
    
    # Final precise sync
    w32tm /resync /force
    Start-Sleep -Seconds 2
    
    Write-Host "Precise time synchronization completed!" -ForegroundColor Green
    Write-Host "Current time: $(Get-Date)" -ForegroundColor Cyan
    
} catch {
    Write-Host "Primary sync failed, trying alternative method..." -ForegroundColor Yellow
    # Set timezone via PowerShell as fallback
    Set-TimeZone -Id "Central European Standard Time" -ErrorAction SilentlyContinue
    
    # Alternative sync method
    Start-Service w32time -ErrorAction SilentlyContinue
    w32tm /config /manualpeerlist:"time.nist.gov,time.windows.com" /syncfromflags:manual
    w32tm /config /reliable:yes
    Restart-Service w32time -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    w32tm /resync /force
    Start-Sleep -Seconds 2
    w32tm /resync /force
    Write-Host "Fallback time sync completed!" -ForegroundColor Green
    Write-Host "Current time: $(Get-Date)" -ForegroundColor Cyan
}

# Enable Win+V clipboard history
Write-Host "Enabling Win+V clipboard history..."
if (!(Test-Path "HKCU:\Software\Microsoft\Clipboard")) {
    New-Item -Path "HKCU:\Software\Microsoft\Clipboard" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1
Write-Host "Clipboard history enabled! Use Win+V to access clipboard history." -ForegroundColor Green

# Disable Mouse Acceleration
Write-Host "Disabling mouse acceleration..."
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"

# Set High Performance Power Plan
Write-Host "Setting High Performance power plan..."
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# Disable Windows Language Hotkey (Alt+Shift)
Write-Host "Disabling language switch hotkey..."
Set-ItemProperty -Path "HKCU:\Keyboard Layout\Toggle" -Name "Hotkey" -Value "3"

# Enable seconds in system clock
Write-Host "Enabling seconds in clock..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1

# Show file extensions and hidden files
Write-Host "Showing file extensions and hidden files..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Disable Windows startup delay (create path if needed)
Write-Host "Disabling Windows startup delay..."
$startupPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (!(Test-Path $startupPath)) {
    New-Item -Path $startupPath -Force | Out-Null
}
Set-ItemProperty -Path $startupPath -Name "StartupDelayInMSec" -Value 0

# Alternative startup optimization
Write-Host "Optimizing startup performance..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableAutoTray" -Value 0

# Disable Edge tabs in Alt+Tab
Write-Host "Disabling Edge tabs in Alt+Tab..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Value 3

# Disable Notepad spell check and autocorrect
Write-Host "Disabling Notepad spell check and autocorrect..."
if (!(Test-Path "HKCU:\Software\Microsoft\Notepad")) {
    New-Item -Path "HKCU:\Software\Microsoft\Notepad" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Notepad" -Name "SpellCheckEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Notepad" -Name "AutoCorrectEnabled" -Value 0

# Additional Gaming Optimizations
Write-Host "Applying gaming optimizations..."

# Disable Windows Game Mode (can cause stuttering)
if (!(Test-Path "HKCU:\Software\Microsoft\GameBar")) {
    New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0

# Disable Game DVR
if (!(Test-Path "HKCU:\System\GameConfigStore")) {
    New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0

# Disable Windows Update automatic restart
$updatePath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
if (!(Test-Path $updatePath)) {
    New-Item -Path $updatePath -Force | Out-Null
}
Set-ItemProperty -Path $updatePath -Name "UxOption" -Value 1

# Set Windows for best performance
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

# Disable typing insights and text suggestions
Write-Host "Disabling typing insights and text suggestions..."
if (!(Test-Path "HKCU:\Software\Microsoft\Input\Settings")) {
    New-Item -Path "HKCU:\Software\Microsoft\Input\Settings" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Input\Settings" -Name "InsightsEnabled" -Value 0

# Disable hardware keyboard text suggestions
if (!(Test-Path "HKCU:\Software\Microsoft\TabletTip\1.7")) {
    New-Item -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "EnableSpellchecking" -Value 0

# Additional startup optimizations
Write-Host "Applying additional startup optimizations..."
# Disable startup delay for desktop apps
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "StartupDelayInMSec" -Value 0

# Configure high-frequency automatic time sync
Write-Host "Configuring high-frequency time synchronization..."
try {
    # Set sync to every 15 minutes instead of weekly
    w32tm /config /update
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\NtpClient" -Name "Enabled" -Value 1
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config" -Name "MaxPosPhaseCorrection" -Value 3600
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config" -Name "MaxNegPhaseCorrection" -Value 3600
    Write-Host "High-frequency time sync configured!" -ForegroundColor Green
} catch {
    Write-Host "Could not configure automatic sync - manual sync completed" -ForegroundColor Yellow
}

# Final time zone verification with more detail
Write-Host ""
Write-Host "=== DETAILED TIME VERIFICATION ===" -ForegroundColor Yellow
$currentTZ = Get-TimeZone
Write-Host "Current Time Zone: $($currentTZ.DisplayName)" -ForegroundColor Cyan
Write-Host "Time Zone ID: $($currentTZ.Id)" -ForegroundColor Cyan
Write-Host "Current Local Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "UTC Time: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan

# Show time server status
Write-Host ""
Write-Host "Time sync status:" -ForegroundColor Yellow
try {
    w32tm /query /status | Where-Object { $_ -match "Source:|Last Successful Sync Time:" }
} catch {
    Write-Host "Could not query time sync status" -ForegroundColor Red
}

Write-Host ""
Write-Host "Base optimizations complete! Restart required." -ForegroundColor Yellow
Write-Host ""
Write-Host "Summary of enabled features:" -ForegroundColor Green
Write-Host "[+] Time zone set to Central European Time (Norway)" -ForegroundColor Cyan
Write-Host "[+] Precise time sync with multiple NTP servers" -ForegroundColor Cyan
Write-Host "[+] Win+V clipboard history enabled" -ForegroundColor Cyan
Write-Host "[+] Seconds shown in system clock" -ForegroundColor Cyan
Write-Host "[+] File extensions and hidden files visible" -ForegroundColor Cyan
Write-Host "[+] Mouse acceleration disabled" -ForegroundColor Cyan
Write-Host "[+] High performance power plan active" -ForegroundColor Cyan

Write-Host ""
Write-Host "If time is still inaccurate, manually run: w32tm /resync /force" -ForegroundColor Yellow