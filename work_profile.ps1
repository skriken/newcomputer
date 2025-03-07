# Windows 11 Setup Script
# Comprehensive setup for a fresh Windows 11 PC with developer settings

# First, ensure we're running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Script needs admin privileges. Please run as administrator."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
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

Write-Log "Starting Windows 11 Setup Script at $(Get-Date)"

# ==== PACKAGE MANAGERS INSTALLATION ==== #
Write-Log "Checking and installing package managers..."

# Check if winget is available, if not install it
try {
    winget --version
    Write-Log "Winget is already installed."
} catch {
    Write-Log "Winget not detected. Installing App Installer from Microsoft Store..."
    # For newer Windows 11 builds, winget should be pre-installed
    # If not, we'll attempt to install it via direct download
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
    } else {
        Write-Log "Microsoft.DesktopAppInstaller is already installed."
    }
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
    scoop bucket add versions
    scoop bucket add nerd-fonts
} else {
    Write-Log "Scoop is already installed."
}

# ==== INSTALLING APPLICATIONS ==== #
Write-Log "Beginning software installation..."

# Array of applications to install with their installation methods
$applications = @(
    @{Name = "7-Zip"; Command = "winget install 7zip.7zip" },
    @{Name = "1Password"; Command = "winget install AgileBits.1Password" },
    @{Name = "Python"; Command = "winget install Python.Python.3.11" },
    @{Name = "Node.js"; Command = "winget install OpenJS.NodeJS.LTS" },
    @{Name = "Visual Studio Build Tools"; Command = "winget install Microsoft.VisualStudio.2022.BuildTools" },
    @{Name = "PowerShell 7"; Command = "winget install Microsoft.PowerShell" },
    @{Name = "Git"; Command = "winget install Git.Git" },
    @{Name = "JetBrains Toolbox"; Command = "winget install JetBrains.Toolbox" },
    @{Name = "Beekeeper Studio"; Command = "winget install beekeeper-studio.beekeeper-studio" },
    @{Name = "Termius"; Command = "winget install Termius.Termius" },
    @{Name = "WhatPulse"; Command = "winget install -e --id WhatPulse.WhatPulse" },
    @{Name = "Obsidian"; Command = "winget install Obsidian.Obsidian" },
    @{Name = "Discord"; Command = "winget install Discord.Discord" },
    @{Name = "Logitech G Hub"; Command = "winget install Logitech.GHUB" },
    @{Name = "NVIDIA GeForce Experience"; Command = "winget install Nvidia.GeForceExperience" },
    @{Name = "Elgato Control Center"; Command = "winget install Elgato.ControlCenter" },
    @{Name = "Linear"; Command = "winget install Linear.Linear" },
    @{Name = "Malwarebytes"; Command = "winget install Malwarebytes.Malwarebytes" },
    @{Name = "Microsoft 365"; Command = "winget install Microsoft.Office" }
)

# Install Bun (special installation)
Write-Log "Installing Bun..."
try {
    Invoke-WebRequest -Uri "https://bun.sh/install" | Invoke-Expression
} catch {
    Write-Log "Error installing Bun: $_"
}

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

# ==== CONFIGURING WINDOWS SETTINGS ==== #
Write-Log "Configuring Windows settings..."

# Disable mouse acceleration (precision)
Write-Log "Disabling mouse acceleration..."
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"

# Set system to dark mode
Write-Log "Setting dark mode..."
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f

# Remove Store from taskbar
Write-Log "Removing Store from taskbar..."
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /f

# Enable maximum performance
Write-Log "Setting maximum performance..."
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# Set additional performance options
$powerScheme = powercfg /GETACTIVESCHEME
$guid = $powerScheme.Split("(")[1].Split(")")[0].Trim()
powercfg /SETACVALUEINDEX $guid 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 0
powercfg /SETACVALUEINDEX $guid 54533251-82be-4824-96c1-47b60b740d00 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0

# Fix Edge tabs in Alt+Tab
Write-Log "Configuring Edge tabs in Alt+Tab..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MultiTaskingAltTabFilter" /t REG_DWORD /d 3 /f

# Disable window grouping
Write-Log "Disabling taskbar window grouping..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d 2 /f

# Enable clipboard history
Write-Log "Enabling clipboard history..."
reg add "HKCU\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 1 /f

# Disable sticky keys prompt
Write-Log "Disabling sticky keys prompt..."
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f

# Set Norwegian language and disable language switch
Write-Log "Setting Norwegian language and disabling language switch..."
$languageList = New-WinUserLanguageList nb-NO
$languageList[0].InputMethodTips.Clear()
$languageList[0].InputMethodTips.Add('0414:00000414')
Set-WinUserLanguageList $languageList -Force

# Disable language hotkey
reg add "HKCU\Keyboard Layout\Toggle" /v "Language Hotkey" /t REG_SZ /d "3" /f
reg add "HKCU\Keyboard Layout\Toggle" /v "Hotkey" /t REG_SZ /d "3" /f

# Enable seconds on taskbar clock
Write-Log "Enabling seconds on taskbar clock..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t REG_DWORD /d 1 /f

# ==== DEVELOPER SETTINGS ==== #
Write-Log "Configuring developer settings..."

# Show file extensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f

# Show hidden files
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f

# Show full path in title bar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" /v "FullPath" /t REG_DWORD /d 1 /f

# Show empty drives
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideDrivesWithNoMedia" /t REG_DWORD /d 0 /f

# Display full context menu
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f 2>$null

# ==== SETTING UP WSL ==== #
Write-Log "Setting up WSL..."
try {
    # Enable WSL feature
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    # Install WSL 2
    wsl --install --no-distribution
    
    # Set WSL 2 as default
    wsl --set-default-version 2
    
    # Install Ubuntu
    wsl --install -d Ubuntu
} catch {
    Write-Log "Error setting up WSL: $_"
}

# ==== FINISHING UP ==== #
Write-Log "Setup complete! A system restart is required for all changes to take effect."
Write-Log "Log file is saved at: $logFile"

# Prompt for restart
$restart = Read-Host "Would you like to restart now? (y/n)"
if ($restart -eq "y") {
    Restart-Computer
}

Stop-Transcript
