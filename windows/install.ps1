# LanguageTool Local Setup - Windows
# This script downloads, installs and configures LanguageTool as a local server
# Requirements: Windows 10 or later, internet connection

$installDir = "C:\LanguageTool"
$port = 8081
$ltZipUrl = "https://internal1.languagetool.org/snapshots/LanguageTool-latest-snapshot.zip"
$ltZipPath = "$installDir\LanguageTool.zip"

# --- Check / Install Java ---
Write-Host "Checking if Java is installed..."
$javaInstalled = $null
try {
    $javaInstalled = java -version 2>&1
} catch {
    $javaInstalled = $null
}

if ($null -eq $javaInstalled) {
    Write-Host "Java not found. Installing Eclipse Temurin (Java 21 LTS)..."

    $javaInstallerUrl = "https://api.adoptium.net/v3/installer/latest/21/ga/windows/x64/jre/hotspot/normal/eclipse"
    $javaInstallerPath = "$env:TEMP\temurin-installer.msi"

    Write-Host "Downloading Java installer..."
    Invoke-WebRequest -Uri $javaInstallerUrl -OutFile $javaInstallerPath

    Write-Host "Installing Java silently (this may take a minute)..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"$javaInstallerPath`" ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJavaHome /quiet" -Wait

    Remove-Item $javaInstallerPath

    Write-Host "Reloading environment variables..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-Host "Java ready."
} else {
    Write-Host "Java already installed. Continuing..."
}

# --- Create install folder ---
Write-Host "Creating installation folder at $installDir..."
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
    Write-Host "Folder created."
} else {
    Write-Host "Folder already exists. Skipping."
}

# --- Download LanguageTool ---
Write-Host "Downloading LanguageTool..."
Invoke-WebRequest -Uri $ltZipUrl -OutFile $ltZipPath
Write-Host "Download complete."

# --- Extract ---
Write-Host "Extracting files..."
Expand-Archive -Path $ltZipPath -DestinationPath $installDir -Force
Write-Host "Extraction complete."

# --- Config file ---
$propertiesPath = "$installDir\server.properties"
if (-not (Test-Path $propertiesPath)) {
    New-Item -ItemType File -Path $propertiesPath | Out-Null
    Write-Host "Configuration file created."
}

# --- Autostart setup ---
Write-Host "Setting up autostart..."

$ltDir = Get-ChildItem -Path $installDir -Directory |
         Where-Object { $_.Name -like "LanguageTool-*" } |
         Select-Object -First 1

if ($null -eq $ltDir) {
    Write-Host "Warning: could not find LanguageTool subfolder. Skipping autostart setup."
} else {
    $ltPath = $ltDir.FullName

    $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
    if (-not $javaExe) {
        Write-Host "Warning: could not find java.exe path. Autostart may not work."
        $javaExe = "java"
    } else {
        Write-Host "Java found at: $javaExe"
    }

    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $vbsPath = "$startupFolder\languagetool.vbs"

    $vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "$ltPath"
WshShell.Run """$javaExe"" -jar languagetool-server.jar --port $port --allow-origin", 0
Set WshShell = Nothing
"@

    # Write without BOM so VBScript can read the file correctly
    [System.IO.File]::WriteAllText($vbsPath, $vbsContent, [System.Text.Encoding]::ASCII)
    Write-Host "Autostart file created at: $vbsPath"

    # Start the server now so the user does not need to reboot
    $ltJar = Get-ChildItem -Path $ltPath -Filter "languagetool-server.jar" | Select-Object -First 1
    Write-Host "Starting LanguageTool server in the background..."
    Start-Process -FilePath $javaExe `
                  -ArgumentList "-jar `"$($ltJar.FullName)`" --port $port --allow-origin" `
                  -WorkingDirectory $ltPath `
                  -WindowStyle Hidden
}

Write-Host ""
Write-Host "Installation complete."
Write-Host "LanguageTool is now running on port $port and will start automatically on every login."
Write-Host "You can now configure the browser extension."