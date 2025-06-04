# Work Profile Setup Script  
# Run as Administrator after base script

Write-Host "Setting up Work Profile..." -ForegroundColor Green

# Additional work-specific tweaks
Write-Host "Applying work-specific tweaks..."

# Disable taskbar grouping
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value 2

# Install work applications
$workApps = @(
    "7zip.7zip",
    "Discord.Discord", 
    "AgileBits.1Password",
    "Malwarebytes.Malwarebytes",
    "Oven-sh.Bun",
    "OpenJS.NodeJS",
    "REALiX.HWiNFO",
    "Python.Python.3.12",
    "Git.Git",
    "JetBrains.Toolbox",
    "beekeeper-studio.beekeeper-studio",
    "Termius.Termius",
    "WhatPulse.WhatPulse",
    "Obsidian.Obsidian",
    "Microsoft.Office"
)

foreach ($app in $workApps) {
    Write-Host "Installing $app..."
    winget install $app --silent --accept-source-agreements --accept-package-agreements
}

# Linear (not in winget) 
Write-Host "Note: Download Linear app manually from linear.app"

Write-Host "Work profile setup complete!" -ForegroundColor Green