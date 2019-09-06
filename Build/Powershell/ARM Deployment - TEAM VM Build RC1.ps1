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

$InstallPath = 'C:\Install'
$LabsPath = 'C:\_SQLHACK_\LABS'
$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data Migration'
$Labs2Path = 'C:\_SQLHACK_\LABS\02-SSIS Migration'
$Labs3Path = 'C:\_SQLHACK_\LABS\03-Security'
$Fileshare = 'C:\FILESHARE'

#Create Folders for Labs and Installs
md -Path $LabsPath
md -Path $InstallPath
md -Path $Labs1Path
md -Path $Labs2Path
md -Path $Labs3Path
md -Path $Fileshare 

#Download Items for LAB 01
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20LAB%20-%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20LAB%20and%20Parameters.docx?raw=true' -OutFile "$Labs1Path\Hands-on Lab - Data Migration.docx"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20LAB%20-%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"

#Download Items for LAB 02

#Download Items for LAB 03

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2088649' -OutFile 'C:\Install\SSMS-Setup.exe' | Wait-Process
$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
Invoke-Command -ScriptBlock $pathArgs

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile "$InstallPath\DataMigrationAssistant.msi"
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru | wait-process

# Download and install SSDT
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2095463' -OutFile 'C:\Install\SSDT-Setup-ENU.exe' | wait-process
Start-Process -file 'C:\Install\SSDT-Setup-ENU.exe' -arg '/layout c:\Install\ssdt_install_bits /passive /log C:\Install\SSDTLayout_install.txt' -wait
Start-Process -file 'C:\Install\ssdt_install_bits\SSDT-Setup-enu.exe' -arg '/install INSTALLIS /passive /norestart /log C:\Install\SSDT_install.txt' -wait

# Create Shortcut on desktop
$TargetFile   = "C:\_SQLHACK_\"
$ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

