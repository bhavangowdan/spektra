param(
    [Parameter(Mandatory = $true)]
    [string]
    $vmAdminUsername,
    [string]
    $vmAdminPassword
)

#---------------------------------------------------------------
# SBID AI Hackathon - Environment Setup Script
# Event Date : 12th June 2026
# Client     : SBID.cz
# Purpose    : Pre-install all required tools for AI Hackathon
# Version    : 1.5
# Changes    : Removed Contoso Invoicing & Excel shortcut
#              Fixed Claude VS Code extension IDs
#              Updated VM SKU to Standard_D4s_v5
#---------------------------------------------------------------

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

#---------------------------------------------------------------
# Import Common Functions
#---------------------------------------------------------------
$path = Get-Location
$path = $path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1
CreateLabFilesDirectory
DisableWindowsFirewall

function Refresh-PathEnv {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Output "PATH environment variable refreshed."
}

$PublicDesktop = "C:\Users\Public\Desktop"
$labPath = "C:\LabFiles"
$ToolsDir = "C:\Tools"

if (!(Test-Path $labPath)) {
    New-Item -Path $labPath -ItemType Directory | Out-Null
}
if (!(Test-Path $ToolsDir)) {
    New-Item -Path $ToolsDir -ItemType Directory | Out-Null
}

#---------------------------------------------------------------
# 1. Disable Windows Privacy Experience at first sign-in
#---------------------------------------------------------------
try {
    Write-Output "=== Disabling Windows Privacy Experience ==="
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" `
        -Name "DisablePrivacyExperience" -Value 1 -Type DWord

    # Disable Location service
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
        -Name "DisableLocation" -Value 1 -Type DWord

    # Disable Location capability access
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" `
        -Name "Value" -Value "Deny"

    Write-Output "Privacy experience and location disabled successfully."
}
catch {
    Write-Output "ERROR disabling privacy experience: $_"
}

#---------------------------------------------------------------
# 2. Disable ALL Windows 11 Popups & Notifications [v1.4]
#---------------------------------------------------------------
try {
    Write-Output "=== Disabling Windows 11 Popups & Notifications ==="

    # --- MACHINE-WIDE (HKLM) Settings ---

    # Disable Windows Copilot icon on taskbar
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
        -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

    # Disable Widgets / News and Interests
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
        -Name "AllowNewsAndInterests" -Value 0 -Type DWord

    # Disable Start Menu Recommendations
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
        -Name "HideRecommendedSection" -Value 1 -Type DWord

    # Disable Search Highlights / Bing in search
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
        -Name "EnableDynamicContentInWSB" -Value 0 -Type DWord

    # Disable "Finish setting up" nag via OOBE
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" `
        -Name "DisablePrivacyExperience" -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Disable Server Manager popup (if applicable)
    $regPath = "HKLM:\SOFTWARE\Microsoft\ServerManager"
    if (Test-Path $regPath) {
        Set-ItemProperty -Path $regPath -Name "DoNotOpenServerManagerAtLogon" -Value 1
    }

    Write-Output "Machine-wide popup settings applied."

    # --- PER-USER Settings (Load Default User + Labuser Hive) ---
    $defaultHivePath = "C:\Users\Default\NTUSER.DAT"
    reg load "HKU\DefaultUser" $defaultHivePath 2>$null

    $labUserHivePath = "C:\Users\$vmAdminUsername\NTUSER.DAT"
    $labUserHiveLoaded = $false
    if (Test-Path $labUserHivePath) {
        reg load "HKU\LabUser" $labUserHivePath 2>$null
        $labUserHiveLoaded = $true
    }

    $hives = @("HKU\DefaultUser")
    if ($labUserHiveLoaded) { $hives += "HKU\LabUser" }

    foreach ($hive in $hives) {
        Write-Output "Applying popup settings to $hive ..."

        $engagementKey = "$hive\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
        reg add $engagementKey /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f 2>$null

        $cdmKey = "$hive\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        reg add $cdmKey /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "PreInstalledAppsEnabled" /t REG_DWORD /d 0 /f 2>$null
        reg add $cdmKey /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d 0 /f 2>$null

        $explorerKey = "$hive\SOFTWARE\Policies\Microsoft\Windows\Explorer"
        reg add $explorerKey /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f 2>$null

        Write-Output "Popup settings applied to $hive."
    }

    reg unload "HKU\DefaultUser" 2>$null
    if ($labUserHiveLoaded) { reg unload "HKU\LabUser" 2>$null }

    Write-Output "All Windows 11 popups and notifications disabled successfully."
}
catch {
    Write-Output "ERROR disabling Windows 11 popups: $_"
    reg unload "HKU\DefaultUser" 2>$null
    reg unload "HKU\LabUser" 2>$null
}

#---------------------------------------------------------------
# 3. Disable Windows Update Service
#---------------------------------------------------------------
try {
    Write-Output "=== Stopping Windows Update service ==="
    $wuauserv = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($wuauserv -and $wuauserv.Status -ne "Stopped") {
        Stop-Service -Name wuauserv -Force
    }
    Set-Service -Name wuauserv -StartupType Disabled
    Write-Output "Windows Update disabled."
}
catch {
    Write-Output "ERROR disabling Windows Update: $_"
}

#---------------------------------------------------------------
# 4. Install Microsoft Edge
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Microsoft Edge ==="
    $edgeInstaller = "$labPath\MicrosoftEdgeEnterpriseX64.msi"
    $edgeUrl = "https://aka.ms/edge-msi"
    Invoke-WebRequest -Uri $edgeUrl -OutFile $edgeInstaller -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$edgeInstaller`" /qn /norestart" -Wait

    # Create Edge Shortcut
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (!(Test-Path $edgePath)) {
        $edgePath = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    }
    if (Test-Path $edgePath) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$PublicDesktop\Microsoft Edge.lnk")
        $Shortcut.TargetPath = $edgePath
        $Shortcut.Save()
        Write-Output "Edge shortcut created."
    }
    else {
        Write-Output "Edge installed but executable not found."
    }
}
catch {
    Write-Output "ERROR installing Microsoft Edge: $_"
}

#---------------------------------------------------------------
# 5. Install .NET 8 Desktop Runtime (x64 + x86)
#---------------------------------------------------------------
try {
    Write-Output "=== Installing .NET 8 Desktop Runtime ==="

    # x64 Runtime
    $dotnetX64 = "$labPath\dotnet8-x64.exe"
    Invoke-WebRequest -Uri "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe" -OutFile $dotnetX64 -UseBasicParsing
    Start-Process -FilePath $dotnetX64 -ArgumentList "/install /quiet /norestart" -Wait

    # x86 Runtime (REQUIRED even on x64 OS)
    $dotnetX86 = "$labPath\dotnet8-x86.exe"
    Invoke-WebRequest -Uri "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x86.exe" -OutFile $dotnetX86 -UseBasicParsing
    Start-Process -FilePath $dotnetX86 -ArgumentList "/install /quiet /norestart" -Wait

    Start-Sleep -Seconds 20
    Write-Output ".NET 8 Desktop Runtime installation completed."
}
catch {
    Write-Output "ERROR installing .NET 8 Runtime: $_"
}

#---------------------------------------------------------------
# 6. Install Power Automate Desktop
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Power Automate Desktop ==="
    $padInstaller = "$labPath\Setup.Microsoft.PowerAutomate.exe"
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2102613" -OutFile $padInstaller -UseBasicParsing
    Start-Process -FilePath $padInstaller `
        -ArgumentList "-Silent -Install -ACCEPTEULA" `
        -Wait
    Start-Sleep -Seconds 20
    Write-Output "Power Automate Desktop installed successfully."
}
catch {
    Write-Output "ERROR installing Power Automate Desktop: $_"
}

#---------------------------------------------------------------
# 7. Install Visual Studio Code
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Visual Studio Code ==="
    $vsCodeInstaller = "$labPath\VSCodeSetup.exe"
    Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" -OutFile $vsCodeInstaller -UseBasicParsing
    Start-Process -FilePath $vsCodeInstaller -ArgumentList "/verysilent /norestart /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait -NoNewWindow
    Refresh-PathEnv

    # Create VS Code shortcut
    $vsCodePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    if (Test-Path $vsCodePath) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$PublicDesktop\Visual Studio Code.lnk")
        $Shortcut.TargetPath = $vsCodePath
        $Shortcut.WorkingDirectory = "C:\Users\$vmAdminUsername"
        $Shortcut.Description = "Visual Studio Code"
        $Shortcut.Save()
        Write-Output "VS Code shortcut created."
    }
    Write-Output "Visual Studio Code installed successfully."
}
catch {
    Write-Output "ERROR installing VS Code: $_"
}

#---------------------------------------------------------------
# 8. Install Node.js LTS
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Node.js LTS ==="
    $nodeInstaller = "$labPath\node-lts.msi"
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi" -OutFile $nodeInstaller -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /qn /norestart" -Wait
    Refresh-PathEnv
    Write-Output "Node.js installed successfully."

    # Verify installation
    $nodeVersion = & node --version 2>&1
    $npmVersion = & npm --version 2>&1
    Write-Output "Node.js version: $nodeVersion"
    Write-Output "npm version: $npmVersion"
}
catch {
    Write-Output "ERROR installing Node.js: $_"
}

#---------------------------------------------------------------
# 9. Install VS Code Extensions for Labuser [FIXED v1.5]
#    - Fixed Claude extension IDs (publisher: anthropics)
#    - Extensions install into Labuser profile, not SYSTEM
#    - Added verification and retry logic
#---------------------------------------------------------------
try {
    Write-Output "=== Installing VS Code Extensions for $vmAdminUsername ==="

    $codePath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
    $extensionsDir = "C:\Users\$vmAdminUsername\.vscode\extensions"

    # Create extensions directory for Labuser
    New-Item -ItemType Directory -Force -Path $extensionsDir | Out-Null
    Write-Output "Created extensions directory: $extensionsDir"

    # Extension 1: Power Platform Tools
    Write-Output "--- Installing Extension 1: Power Platform Tools ---"
    $ext1Result = Start-Process -FilePath $codePath `
        -ArgumentList "--install-extension microsoft-IsvExpTools.powerplatform-vscode-extension --force --extensions-dir `"$extensionsDir`"" `
        -Wait -NoNewWindow -PassThru
    if ($ext1Result.ExitCode -eq 0) {
        Write-Output "SUCCESS: Power Platform Tools Extension installed (ExitCode: $($ext1Result.ExitCode))"
    } else {
        Write-Output "WARNING: Power Platform Tools install returned ExitCode: $($ext1Result.ExitCode)"
    }
    Start-Sleep -Seconds 10

    # Extension 2: Claude for VS Code (Chat/Sidebar)
    # Publisher: anthropics (with 's'), Extension ID: anthropics.claude
    Write-Output "--- Installing Extension 2: Claude for VS Code (anthropics.claude) ---"
    $ext2Result = Start-Process -FilePath $codePath `
        -ArgumentList "--install-extension anthropics.claude --force --extensions-dir `"$extensionsDir`"" `
        -Wait -NoNewWindow -PassThru
    if ($ext2Result.ExitCode -eq 0) {
        Write-Output "SUCCESS: Claude for VS Code Extension installed (ExitCode: $($ext2Result.ExitCode))"
    } else {
        Write-Output "WARNING: Claude for VS Code install returned ExitCode: $($ext2Result.ExitCode)"
        Write-Output "Trying alternative ID: anthropic.claude-code ..."
        $ext2Retry = Start-Process -FilePath $codePath `
            -ArgumentList "--install-extension anthropic.claude-code --force --extensions-dir `"$extensionsDir`"" `
            -Wait -NoNewWindow -PassThru
        if ($ext2Retry.ExitCode -eq 0) {
            Write-Output "SUCCESS: Claude Code Extension installed via alternative ID (ExitCode: $($ext2Retry.ExitCode))"
        } else {
            Write-Output "WARNING: Claude alternative ID also returned ExitCode: $($ext2Retry.ExitCode)"
        }
    }
    Start-Sleep -Seconds 10

    # Extension 3: Claude Code (Terminal-based)
    # Publisher: anthropics, Extension ID: anthropics.claude-code
    Write-Output "--- Installing Extension 3: Claude Code Terminal (anthropics.claude-code) ---"
    $ext3Result = Start-Process -FilePath $codePath `
        -ArgumentList "--install-extension anthropics.claude-code --force --extensions-dir `"$extensionsDir`"" `
        -Wait -NoNewWindow -PassThru
    if ($ext3Result.ExitCode -eq 0) {
        Write-Output "SUCCESS: Claude Code Terminal Extension installed (ExitCode: $($ext3Result.ExitCode))"
    } else {
        Write-Output "INFO: Claude Code Terminal extension not available in marketplace (ExitCode: $($ext3Result.ExitCode)) - Skipping."
    }
    Start-Sleep -Seconds 10

    # Set proper ownership/permissions for Labuser
    $acl = Get-Acl "C:\Users\$vmAdminUsername\.vscode"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$vmAdminUsername", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.SetAccessRule($rule)
    Set-Acl "C:\Users\$vmAdminUsername\.vscode" $acl
    Write-Output "Permissions set on .vscode folder for $vmAdminUsername."

    # Verify all installed extensions
    Write-Output "=== Verifying Installed Extensions ==="
    $installedExtensions = Get-ChildItem -Path $extensionsDir -Directory -ErrorAction SilentlyContinue
    if ($installedExtensions.Count -gt 0) {
        Write-Output "Extensions found in $extensionsDir ($($installedExtensions.Count) total):"
        foreach ($ext in $installedExtensions) {
            Write-Output "  [OK] $($ext.Name)"
        }
    } else {
        Write-Output "WARNING: No extensions found in $extensionsDir"
        Write-Output "Attempting system-wide fallback install..."
        # Fallback: install system-wide (will be available to all users)
        Start-Process -FilePath $codePath -ArgumentList "--install-extension microsoft-IsvExpTools.powerplatform-vscode-extension --force" -Wait -NoNewWindow
        Start-Process -FilePath $codePath -ArgumentList "--install-extension anthropics.claude --force" -Wait -NoNewWindow
        Write-Output "System-wide fallback install attempted."
    }
}
catch {
    Write-Output "ERROR installing VS Code Extensions: $_"
}

#---------------------------------------------------------------
# 10. Install Claude Code via npm
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Claude Code via npm ==="
    Refresh-PathEnv
    $npmPath = (Get-Command npm -ErrorAction Stop).Source
    Start-Process -FilePath $npmPath -ArgumentList "install -g @anthropic-ai/claude-code" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Output "Claude Code installed successfully via npm."
}
catch {
    Write-Output "ERROR installing Claude Code: $_"
}

#---------------------------------------------------------------
# 11. Install .NET SDK 8.0 (required for PAC CLI)
#---------------------------------------------------------------
try {
    Write-Output "=== Installing .NET SDK 8.0 ==="
    Invoke-WebRequest -Uri "https://dot.net/v1/dotnet-install.ps1" -OutFile "$labPath\dotnet-install.ps1" -UseBasicParsing
    & "$labPath\dotnet-install.ps1" -Channel 8.0 -InstallDir "C:\Program Files\dotnet"

    # Add dotnet to PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*dotnet*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\Program Files\dotnet", "Machine")
    }
    Refresh-PathEnv
    Write-Output ".NET SDK 8.0 installed successfully."
}
catch {
    Write-Output "ERROR installing .NET SDK: $_"
}

#---------------------------------------------------------------
# 12. Install PAC CLI (Power Platform CLI)
#---------------------------------------------------------------
try {
    Write-Output "=== Installing PAC CLI (Power Platform CLI) ==="
    Refresh-PathEnv
    $dotnetPath = "C:\Program Files\dotnet\dotnet.exe"
    Start-Process -FilePath $dotnetPath -ArgumentList "tool install --global Microsoft.PowerApps.CLI.Tool" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Output "PAC CLI installed successfully."
}
catch {
    Write-Output "ERROR installing PAC CLI: $_"
}

#---------------------------------------------------------------
# 13. Install Git (required for cloning repos)
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Git ==="
    $gitInstaller = "$labPath\Git-Setup.exe"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe" -OutFile $gitInstaller -UseBasicParsing
    Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=icons,ext\reg\shellhere,assoc,assoc_sh" -Wait -NoNewWindow
    Refresh-PathEnv
    Write-Output "Git installed successfully."
}
catch {
    Write-Output "ERROR installing Git: $_"
}

#---------------------------------------------------------------
# 14. Clone Power Platform Skills
#---------------------------------------------------------------
try {
    Write-Output "=== Cloning Power Platform Skills ==="
    Refresh-PathEnv
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/power-platform-skills.git `"$ToolsDir\power-platform-skills`"" -Wait -NoNewWindow
    Write-Output "Power Platform Skills cloned to $ToolsDir\power-platform-skills"
}
catch {
    Write-Output "ERROR cloning Power Platform Skills: $_"
}

#---------------------------------------------------------------
# 15. Clone Dataverse Skills (for Claude Code)
#---------------------------------------------------------------
try {
    Write-Output "=== Cloning Dataverse Skills ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/Dataverse-skills.git `"$ToolsDir\Dataverse-skills`"" -Wait -NoNewWindow
    Write-Output "Dataverse Skills cloned to $ToolsDir\Dataverse-skills"
}
catch {
    Write-Output "ERROR cloning Dataverse Skills: $_"
}

#---------------------------------------------------------------
# 16. Clone Power BI Agentic Development (Claude Code plugin)
#---------------------------------------------------------------
try {
    Write-Output "=== Cloning Power BI Agentic Development ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/data-goblin/power-bi-agentic-development.git `"$ToolsDir\power-bi-agentic-development`"" -Wait -NoNewWindow
    Write-Output "Power BI Agentic Development cloned to $ToolsDir\power-bi-agentic-development"
}
catch {
    Write-Output "ERROR cloning Power BI Agentic Development: $_"
}

#---------------------------------------------------------------
# 17. Clone Copilot Studio Skills
#---------------------------------------------------------------
try {
    Write-Output "=== Cloning Copilot Studio Skills ==="
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    Start-Process -FilePath $gitPath -ArgumentList "clone https://github.com/microsoft/skills-for-copilot-studio.git `"$ToolsDir\skills-for-copilot-studio`"" -Wait -NoNewWindow
    Write-Output "Copilot Studio Skills cloned to $ToolsDir\skills-for-copilot-studio"
}
catch {
    Write-Output "ERROR cloning Copilot Studio Skills: $_"
}

#---------------------------------------------------------------
# 18. Install Power BI Desktop
#---------------------------------------------------------------
try {
    Write-Output "=== Installing Power BI Desktop ==="
    $pbiInstaller = "$labPath\PBIDesktopSetup_x64.exe"
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe" -OutFile $pbiInstaller -UseBasicParsing
    Start-Process -FilePath $pbiInstaller -ArgumentList "-quiet -norestart ACCEPT_EULA=1" -Wait -NoNewWindow
    Write-Output "Power BI Desktop installed successfully."
}
catch {
    Write-Output "ERROR installing Power BI Desktop: $_"
}

#---------------------------------------------------------------
# 19. Create AI Hackathon Tools Shortcut
#---------------------------------------------------------------
try {
    Write-Output "=== Creating AI Hackathon Tools Shortcut ==="
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$PublicDesktop\AI Hackathon Tools.lnk")
    $Shortcut.TargetPath = $ToolsDir
    $Shortcut.Description = "AI Hackathon Tools & Repos"
    $Shortcut.Save()
    Write-Output "AI Hackathon Tools shortcut created."
}
catch {
    Write-Output "ERROR creating Tools shortcut: $_"
}

#---------------------------------------------------------------
# 20. Enable CloudLabs Embedded Shadow
#---------------------------------------------------------------
try {
    Write-Output "=== Enabling CloudLabs Embedded Shadow ==="
    Enable-CloudLabsEmbeddedShadow -trainerUserName $vmAdminUsername -trainerUserPassword $vmAdminPassword
    Write-Output "CloudLabs Embedded Shadow enabled successfully."
}
catch {
    Write-Output "ERROR enabling CloudLabs Embedded Shadow: $_"
}

#---------------------------------------------------------------
# Cleanup
#---------------------------------------------------------------
try {
    Write-Output "=== Cleaning up installer files ==="
    Remove-Item -Path "$labPath\*.exe" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$labPath\*.msi" -Force -ErrorAction SilentlyContinue
    Write-Output "Cleanup completed."
}
catch {
    Write-Output "WARNING: Cleanup failed: $_"
}

Write-Output "=========================================="
Write-Output "SBID AI Hackathon setup script completed!"
Write-Output "=========================================="

Stop-Transcript
