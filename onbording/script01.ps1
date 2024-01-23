Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    
    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $DeploymentID,

    [string]
    $adminPassword
   
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
$adminUsername= "Udacity-Student"
net user $adminUsername $adminPassword

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

$FileDir ="C:\Packages"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/udacity-security/scripts/logontask.ps1","C:\Packages\logontask.ps1")


#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath


WindowsServerCommon
InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow
choco install openssh --pre
CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID
InstallAzPowerShellModule




. C:\LabFiles\AzureCreds.ps1

$userName = $AzureUserName
$password = $AzurePassword
$deploymentID = $DeploymentID

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null


$rgName = "entp-02-" + $deploymentID
$vmName = "labvm-" + $deploymentID

Get-AzRemoteDesktopFile -ResourceGroupName "$rgName" -Name "$vmName" -LocalPath "C:\Users\Udacity-Student\Desktop\labvm.rdp"

sleep 10

Unregister-ScheduledTask -TaskName "startextension" -Confirm:$false


Restart-Computer


