﻿
# Disable Internet Explorer Enhanced Security Configuration

function Disable-InternetExplorerESC {

    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"

    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force

    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force

    Stop-Process -Name Explorer -Force

    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

}



# Disable IE ESC

Disable-InternetExplorerESC



# Enable SQL Server ports on the Windows firewall

function Add-SqlFirewallRule {

    $fwPolicy = $null
    $fwPolicy = New-Object -ComObject HNetCfg.FWPolicy2
    
    $NewRule = $null
    $NewRule = New-Object -ComObject HNetCfg.FWRule
    
    $NewRule.Name = "SqlServer"

    # TCP
    $NewRule.Protocol = 6
    $NewRule.LocalPorts = 1433
    $NewRule.Enabled = $True
    $NewRule.Grouping = "SQL Server"

    # ALL
    $NewRule.Profiles = 7

    # ALLOW
    $NewRule.Action = 1

    # Add the new rule
    $fwPolicy.Rules.Add($NewRule)
}

Add-SqlFirewallRule

#Set Veriables
$InstallPath = 'C:\Install'
$BackupPath = 'C:\Backups'

#Create Folders for Labs and Installs
md -Path $InstallPath
md -Path $BackupPath
md -Path "C:\Data"

$InstallPath = 'C:\Install'
$BackupPath = 'C:\Backups'

#Download Sciprts
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/1-%20CREATE%20Logins.sql' -OutFile "$BackupPath\1- CREATE Logins.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/2-%20RESTORE%20Databases.sql' -OutFile "$BackupPath\2- RESTORE Databases.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/3-%20RESTORE%20FIXES.sql' -OutFile "$BackupPath\3- RESTORE FIXES.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/4-DROP%20DATABASES.sql' -OutFile "$BackupPath\4-DROP DATABASES.sql"


#Download & Unzip Backups

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/Database%20Build/Backups.zip?raw=true' -UseBasicParsing -OutFile "$InstallPath\Backups.zip"


Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\Install\Backups.zip" "C:\"

#Run SQL Cmds
sqlcmd -S "(local)" -U "DemoUser" -P "Demo@pass1234567" -i "$BackupPath\1- CREATE Logins.sql"
sqlcmd -S "(local)" -U "DemoUser" -P "Demo@pass1234567" -i "$BackupPath\2- RESTORE Databases.sql"
sqlcmd -S "(local)" -U "DemoUser" -P "Demo@pass1234567" -i "$BackupPath\3- RESTORE FIXES.sql"





