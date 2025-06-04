# Gaming Profile Setup Script
# Run as Administrator after base script

Write-Host "Setting up Gaming Profile..." -ForegroundColor Green

# Install gaming applications via winget
$gamingApps = @(
    "AgileBits.1Password",
    "7zip.7zip", 
    "Discord.Discord",
    "Malwarebytes.Malwarebytes",
    "WhatPulse.WhatPulse",
    "SteelSeries.SteelSeriesGG",
    "Valve.Steam",
    "REALiX.HWiNFO",
    "EpicGames.EpicGamesLauncher",
    "Elgato.ControlCenter",
    "Medal.Medal"
)

foreach ($app in $gamingApps) {
    Write-Host "Installing $app..."
    winget install $app --silent --accept-source-agreements --accept-package-agreements
}

# Special installations (not in winget or different names)
Write-Host "Installing additional gaming software..."

# Armoury Crate (manual download link)
Write-Host "Note: Download Armoury Crate manually from ASUS website"

# League of Legends (via Riot Games)
try {
    winget install "Riot Games.LeagueOfLegends" --silent
} catch {
    Write-Host "Install League of Legends manually from riot website"
}

# Mobalytics (not in winget)
Write-Host "Note: Download Mobalytics manually from mobalytics.gg"

Write-Host "Gaming profile setup complete!" -ForegroundColor Green