param (
    [string]$SASURIKey, 
    [string]$StorageAccount
)

$InstallPath = 'C:\Install'
$LabsPath = 'C:\_SQLHACK_\LABS'
$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data_Migration'
$Labs2Path = 'C:\_SQLHACK_\LABS\02-SSIS_Migration'
$Labs3Path = 'C:\_SQLHACK_\LABS\03-Security'

#Create Folders for Labs and Installs
md -Path $LabsPath
md -Path $InstallPath
md -Path $Labs1Path
md -Path $Labs2Path
md -Path $Labs3Path

$SASURIKey = $SASURIKey | ConvertFrom-Json

#Download Items for LAB 01
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/Background.rtf?raw=true' -OutFile "C:\_SQLHACK_\Lab Background.rtf"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20LAB%20and%20Parameters.docx?raw=true' -OutFile "$Labs1Path\Hands-on Lab - Data Migration.docx"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Hands-On%20Lab/01%20Data%20Migration/Migration%20Helper%20Script.sql' -OutFile "$Labs1Path\Migration Helper Script.txt"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20Lab%20Step-by-step.docx?raw=true' -OutFile "$Labs1Path\DB Migration Lab Step-by-step.docx"

$SASURIKey | out-file -FilePath "$Labs1Path\SASKEY.txt"
$StorageAccount | out-file -FilePath "$Labs1Path\StorageAccount.txt"

#Download Items for LAB 02
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/02%20SSIS%20Migration/02-SSIS%20Migration.zip?raw=true' -OutFile "$InstallPath\Lab2.zip"
$SASURIKey | out-file -FilePath "$Labs2Path\SASKEY.txt"
$StorageAccount | out-file -FilePath "$Labs2Path\StorageAccount.txt"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$InstallPath\Lab2.zip" "$Labs2Path"

#Download Items for LAB 03
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/03%20Security/Hands-on-Lab%20-%20Data%20Security.docx?raw=truee' -OutFile "$Labs3Path\Hands-on Lab - Security.docx"
$StorageAccount | out-file -FilePath "$Labs3Path\StorageAccount.txt"

#Install Applications

# Download and install SSDT
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2095463' -OutFile 'C:\Install\SSDT-Setup-ENU.exe'
Start-Process -file 'C:\Install\SSDT-Setup-ENU.exe' -arg '/layout c:\Install\vs_install_bits /quiet /log C:\Install\SSDTLayout_install.txt' -wait
start-sleep 10
Start-Process -file 'C:\Install\vs_install_bits\SSDT-Setup-enu.exe' -arg '/INSTALLVSSQL /install INSTALLALL /norestart /passive /log C:\Install\SSDT_install.txt' -wait 

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2088649' -OutFile 'C:\Install\SSMS-Setup.exe'
$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
Invoke-Command -ScriptBlock $pathArgs 

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile "$InstallPath\DataMigrationAssistant.msi"
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru 

# Download Storage Explorer
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409' -OutFile "$InstallPath\StorageExplore.exe"
Start-Process -file 'C:\Install\StorageExplore.exe' -arg '/VERYSILENT /NORESTART /LOG C:\Install\StorageExplore_install.txt'

# Create Shortcut on desktop
$TargetFile   = "C:\_SQLHACK_\"
$ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
