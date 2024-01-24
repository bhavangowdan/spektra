Start-Transcript -Path C:\WindowsAzure\Logs\logontask.txt -Append



. C:\LabFiles\AzureCreds.ps1

$userName = $AzureUserName
$password = $AzurePassword
$deploymentID = $DeploymentID

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;


Connect-AzAccount -Credential $cred | Out-Null


$rgName = "entp-02-" + $deploymentID
$vmName = "labvm-" + $deploymentID

New-Item -Path "C:\Users\Udacity-Student\Desktop\" -Name "test.txt" -ItemType Directory

Get-AzRemoteDesktopFile -ResourceGroupName "$rgName" -Name "$vmName" -LocalPath "C:\Users\Udacity-Student\Desktop\labvm.rdp"

Remove-Item -Path C:\Users\Udacity-Student\Desktop\test.txt -Force

sleep 10

Unregister-ScheduledTask -TaskName "startextension" -Confirm:$false
