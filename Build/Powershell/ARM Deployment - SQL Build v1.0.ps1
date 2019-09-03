
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


#Download Sciprts
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/1-%20CREATE%20Logins.sql' -OutFile "$BackupPath\1- CREATE Logins.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/2-%20RESTORE%20Databases.sql' -OutFile "$BackupPath\2- RESTORE Databases.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/3-%20RESTORE%20FIXES.sql' -OutFile "$BackupPath\3- RESTORE FIXES.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/4-DROP%20DATABASES.sql' -OutFile "$BackupPath\4-DROP DATABASES.sql"




Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20LAB%20-%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"


#Download Backups






