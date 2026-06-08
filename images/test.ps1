Param (
    [Parameter(Mandatory=$true)]
    [string]$vmAdminUserName,

    [Parameter(Mandatory=$true)]
    [string]$vmAdminPassword
)

#---------------------------------------------------------------
# SBID AI Hackathon - Environment Setup Script
# Event Date : 12th June 2026
# Client     : SBID.cz
# Purpose    : Pre-install all required tools for AI Hackathon
#---------------------------------------------------------------

# Import CloudLabs common functions
. C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\*\Downloads\*\cloudlabs-common\cloudlabs-windows-functions.ps1

# Log file path
$LogFile = "C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt"

# Start logging
Start-Transcript -Path $LogFile -Append

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

function Refresh-PathEnv {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Log "PATH environment variable refreshed."
}

# Create directories
$ToolsDir = "C:\Tools"
$InstallerDir = "C:\Temp\Installers"
New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
New-Item -ItemType Directory -Force -Path $InstallerDir | Out-Null
Write-Log "Created directories: $ToolsDir, $InstallerDir"

#---------------------------------------------------------------
# 1. Install Visual Studio Code
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Visual Studio Code ==="
    $vsCodeInstaller = "$InstallerDir\VSCodeSetup.exe"
    Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile $vsCodeInstaller -UseBasicParsing
    Start-Process -FilePath $vsCodeInstaller -ArgumentList "/verysilent /norestart /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Log "Visual Studio Code installed successfully."
}
catch {
    Write-Log "ERROR installing VS Code: $_"
}

#---------------------------------------------------------------
# 2. Install Node.js LTS
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Node.js LTS ==="
    $nodeInstaller = "$InstallerDir\node-lts.msi"
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi" -OutFile $nodeInstaller -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /qn /norestart" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Log "Node.js installed successfully."

    # Verify installation
    $nodeVersion = & node --version 2>&1
    $npmVersion = & npm --version 2>&1
    Write-Log "Node.js version: $nodeVersion"
    Write-Log "npm version: $npmVersion"
}
catch {
    Write-Log "ERROR installing Node.js: $_"
}

#---------------------------------------------------------------
# 3. Install Power Platform Tools Extension for VS Code
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Power Platform Tools Extension for VS Code ==="
    $codePath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
    Start-Process -FilePath $codePath -ArgumentList "--install-extension microsoft-IsvExpTools.powerplatform-vscode-extension --force" -Wait -NoNewWindow
    Write-Log "Power Platform Tools Extension installed successfully."
}
catch {
    Write-Log "ERROR installing Power Platform Tools Extension: $_"
}

#---------------------------------------------------------------
# 4. Install Claude Code via npm
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Claude Code via npm ==="
    Refresh-PathEnv
    $npmPath = (Get-Command npm -ErrorAction Stop).Source
    Start-Process -FilePath $npmPath -ArgumentList "install -g @anthropic-ai/claude-code" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Log "Claude Code installed successfully via npm."
}
catch {
    Write-Log "ERROR installing Claude Code: $_"
}

#---------------------------------------------------------------
# 5. Install Claude Code Extension for VS Code
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Claude Code Extension for VS Code ==="
    $codePath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
    Start-Process -FilePath $codePath -ArgumentList "--install-extension anthropic.claude-code --force" -Wait -NoNewWindow
    Write-Log "Claude Code Extension installed successfully."
}
catch {
    Write-Log "ERROR installing Claude Code Extension: $_"
}

#---------------------------------------------------------------
# 6. Install .NET SDK (required for PAC CLI)
#---------------------------------------------------------------
try {
    Write-Log "=== Installing .NET SDK ==="
    $dotnetInstaller = "$InstallerDir\dotnet-sdk.exe"
    Invoke-WebRequest -Uri "https://dot.net/v1/dotnet-install.ps1" -OutFile "$InstallerDir\dotnet-install.ps1" -UseBasicParsing
    & "$InstallerDir\dotnet-install.ps1" -Channel 8.0 -InstallDir "C:\Program Files\dotnet"

    # Add dotnet to PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*dotnet*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\Program Files\dotnet", "Machine")
    }
    Refresh-PathEnv
    Write-Log ".NET SDK installed successfully."
}
catch {
    Write-Log "ERROR installing .NET SDK: $_"
}

#---------------------------------------------------------------
# 7. Install PAC CLI (Power Platform CLI)
#---------------------------------------------------------------
try {
    Write-Log "=== Installing PAC CLI (Power Platform CLI) ==="
    Refresh-PathEnv
    $dotnetPath = "C:\Program Files\dotnet\dotnet.exe"
    Start-Process -FilePath $dotnetPath -ArgumentList "tool install --global Microsoft.PowerApps.CLI.Tool" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Log "PAC CLI installed successfully."
}
catch {
    Write-Log "ERROR installing PAC CLI: $_"
}

#---------------------------------------------------------------
# 8. Install Git (required for cloning repos)
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Git ==="
    $gitInstaller = "$InstallerDir\Git-Setup.exe"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe" -OutFile $gitInstaller -UseBasicParsing
    Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=icons,ext\reg\shellhere,assoc,assoc_sh" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Log "Git installed successfully."
}
catch {
    Write-Log "ERROR installing Git: $_"
}

#---------------------------------------------------------------
# 9. Clone Power Platform Skills
#---------------------------------------------------------------
try {
    Write-Log "=== Cloning Power Platform Skills ==="
    Refresh-PathEnv
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/power-platform-skills.git `"$ToolsDir\power-platform-skills`"" -Wait -NoNewWindow
    Write-Log "Power Platform Skills cloned to $ToolsDir\power-platform-skills"
}
catch {
    Write-Log "ERROR cloning Power Platform Skills: $_"
}

#---------------------------------------------------------------
# 10. Clone Dataverse Skills (for Claude Code)
#---------------------------------------------------------------
try {
    Write-Log "=== Cloning Dataverse Skills ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/Dataverse-skills.git `"$ToolsDir\Dataverse-skills`"" -Wait -NoNewWindow
    Write-Log "Dataverse Skills cloned to $ToolsDir\Dataverse-skills"
}
catch {
    Write-Log "ERROR cloning Dataverse Skills: $_"
}

#---------------------------------------------------------------
# 11. Clone Power BI Agentic Development (Claude Code plugin)
#---------------------------------------------------------------
try {
    Write-Log "=== Cloning Power BI Agentic Development ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/data-goblin/power-bi-agentic-development.git `"$ToolsDir\power-bi-agentic-development`"" -Wait -NoNewWindow
    Write-Log "Power BI Agentic Development cloned to $ToolsDir\power-bi-agentic-development"
}
catch {
    Write-Log "ERROR cloning Power BI Agentic Development: $_"
}

#---------------------------------------------------------------
# 12. Clone Copilot Studio Skills
#---------------------------------------------------------------
try {
    Write-Log "=== Cloning Copilot Studio Skills ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/skills-for-copilot-studio.git `"$ToolsDir\skills-for-copilot-studio`"" -Wait -NoNewWindow
    Write-Log "Copilot Studio Skills cloned to $ToolsDir\skills-for-copilot-studio"
}
catch {
    Write-Log "ERROR cloning Copilot Studio Skills: $_"
}

#---------------------------------------------------------------
# 13. Install Power BI Desktop
#---------------------------------------------------------------
try {
    Write-Log "=== Installing Power BI Desktop ==="
    $pbiInstaller = "$InstallerDir\PBIDesktopSetup_x64.exe"
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe" -OutFile $pbiInstaller -UseBasicParsing
    Start-Process -FilePath $pbiInstaller -ArgumentList "-quiet -norestart ACCEPT_EULA=1" -Wait -NoNewWindow
    Write-Log "Power BI Desktop installed successfully."
}
catch {
    Write-Log "ERROR installing Power BI Desktop: $_"
}

#---------------------------------------------------------------
# 14. Create Desktop Shortcuts
#---------------------------------------------------------------
try {
    Write-Log "=== Creating Desktop Shortcuts ==="
    $desktopPath = "C:\Users\Public\Desktop"

    # VS Code shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut("$desktopPath\Visual Studio Code.lnk")
    $shortcut.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
    $shortcut.WorkingDirectory = "C:\Users\$vmAdminUserName"
    $shortcut.Description = "Visual Studio Code"
    $shortcut.Save()

    # Tools Folder shortcut
    $shortcut2 = $WshShell.CreateShortcut("$desktopPath\AI Hackathon Tools.lnk")
    $shortcut2.TargetPath = $ToolsDir
    $shortcut2.Description = "AI Hackathon Tools & Repos"
    $shortcut2.Save()

    Write-Log "Desktop shortcuts created successfully."
}
catch {
    Write-Log "ERROR creating desktop shortcuts: $_"
}

#---------------------------------------------------------------
# 15. Disable Server Manager popup (if applicable)
#---------------------------------------------------------------
try {
    Write-Log "=== Disabling Server Manager popup ==="
    $regPath = "HKLM:\SOFTWARE\Microsoft\ServerManager"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "DoNotOpenServerManagerAtLogon" -Value 1
    }
    Write-Log "Server Manager popup disabled."
}
catch {
    Write-Log "WARNING: Could not disable Server Manager popup: $_"
}

#---------------------------------------------------------------
# 16. Enable CloudLabs Embedded Shadow
#---------------------------------------------------------------
try {
    Write-Log "=== Enabling CloudLabs Embedded Shadow ==="
    Enable-CloudLabsEmbeddedShadow -vmAdminUsername $vmAdminUserName -vmAdminPassword $vmAdminPassword
    Write-Log "CloudLabs Embedded Shadow enabled successfully."
}
catch {
    Write-Log "ERROR enabling CloudLabs Embedded Shadow: $_"
}

#---------------------------------------------------------------
# Cleanup
#---------------------------------------------------------------
try {
    Write-Log "=== Cleaning up installer files ==="
    Remove-Item -Path $InstallerDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Cleanup completed."
}
catch {
    Write-Log "WARNING: Cleanup failed: $_"
}

Write-Log "=========================================="
Write-Log "SBID AI Hackathon setup script completed!"
Write-Log "=========================================="

Stop-Transcript
