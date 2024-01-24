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

Install-Module -Name Az -Repository PSGallery -Force



Start-Process powershell.exe -ArgumentList "-File C:\Packages\logontask.ps1" -Wait

Restart-Computer


