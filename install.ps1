## == INSTRUCTIONS == ##
# 1. Open CMD as admin
# 2. Run this: powershell -ExecutionPolicy Bypass -NoExit -File test.ps1
# 3. You're done!

## == INITIAL SETUP == ##

# First, ensure we're running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Script needs admin privileges. Please run as administrator."
    exit
}

# Create log file
$logFile = "setup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
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

# Check if Scoop is installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Scoop..."

    # Set execution policy
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # Download and install Scoop
    Invoke-RestMethod get.scoop.sh | Invoke-Expression

    # Add extras bucket (needed for some packages)
    scoop bucket add extras
} else {
    Write-Log "Scoop is already installed."
}

## == INSTALLING DEVELOPER TOOLS == ##
Write-Log "Beginning software installation..."

# 7-Zip
winget install 7zip.7zip

# Python (latest)
winget install Python.Python.3.11

# Node.js
winget install OpenJS.NodeJS

# Install Bun
powershell -c "curl https://bun.sh/install | powershell"

# VS Build Tools
winget install Microsoft.VisualStudio.2022.BuildTools

# PowerShell 7
winget install Microsoft.PowerShell

# JetBrains Toolbox
winget install JetBrains.Toolbox

# Git
winget install Git.Git

# WebStorm
winget install JetBrains.WebStorm

# Beekeeper Studio
winget install beekeeper-studio.beekeeper-studio

# Termius
winget install Termius.Termius

# Infisical (secrets manager)
scoop bucket add infisical https://github.com/Infisical/scoop-infisical.git
scoop install infisical

## == INSTALLING PERSONAL APPS == ##
# WhatPulse (monitors your computer usage)
winget install -e --id WhatPulse.WhatPulse

# 1Password
winget install AgileBits.1Password

# Discord
winget install Discord.Discord

# GeForce Experience
winget install Nvidia.GeForceExperience

# Obsidian
winget install Obsidian.Obsidian

# Logitech G Hub
winget install Logitech.GHUB

# Microsoft 365
winget install Microsoft.Office

## == SETTING UP WINDOWS SETTINGS == ##

# Windows Settings Section
Write-Log "Configuring Windows settings..."

# Performance settings
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Dark theme
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f

# Search box to icon
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f

# Remove Store from taskbar
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /v FavoritesMRU /t REG_BINARY /d 0 /f

# Edge browser tabs settings
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MultitaskingView\AltTabViewHost /v GroupByApplication /t REG_DWORD /d 0 /f

# Disable grouped windows
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarGlomLevel /t REG_DWORD /d 2 /f

# Enable clipboard history
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v UseClipboardHistory /t REG_DWORD /d 1 /f

# Disable sticky keys prompt
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d "506" /f

# Disable language switch hotkey
reg add "HKCU\Keyboard Layout\Toggle" /v "Language Hotkey" /t REG_SZ /d "3" /f
reg add "HKCU\Keyboard Layout\Toggle" /v "Hotkey" /t REG_SZ /d "3" /f

Write-Log "Setup complete. Please restart your computer for all changes to take effect."

## == SETTING UP WSL == ##

# WSL Setup
Write-Log "Setting up WSL..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --install -d Ubuntu

Stop-Transcript
