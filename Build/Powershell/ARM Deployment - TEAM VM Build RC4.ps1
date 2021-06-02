param (
    [string]$SASURIKey, 
    [string]$StorageAccount
)

$InstallPath = 'C:\Install'
$LabsPath = 'C:\_SQLHACK_\LABS'
$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data_Migration'
$Labs2Path = 'C:\_SQLHACK_\LABS\02-SSIS_Migration'
$Labs3Path = 'C:\_SQLHACK_\LABS\03-Security'
$Labs3SecurityPath = 'C:\_SQLHACK_\LABS\03-Security\SQLScripts'

##################################################################
#Create Folders for Labs and Installs
##################################################################
md -Path $LabsPath
md -Path $InstallPath
md -Path $Labs1Path
md -Path $Labs2Path
md -Path $Labs3Path
md -Path $Labs3SecurityPath

#$SASURIKey = $SASURIKey | ConvertFrom-Json

#Download Items for LAB 01
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/Background.pdf' -OutFile "C:\_SQLHACK_\Lab Background.pdf"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/01%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20LAB%20and%20Parameters.pdf' -OutFile "$Labs1Path\Hands-on Lab - Data Migration.pdf"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Hands-On%20Lab/01%20Data%20Migration/Migration%20Helper%20Script.sql' -OutFile "$Labs1Path\Migration Helper Script.txt"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/01%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20Lab%20Step-by-step.pdf' -OutFile "$Labs1Path\DB Migration Lab Step-by-step.pdf"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/SQL%20SSIS%20Databases/SSIS%20Build%20Script%20-%20TeamServer.ps1'  -OutFile "$InstallPath\SSIS Build Script.ps1"

$SASURIKey | out-file -FilePath "$Labs1Path\SASKEY.txt"

#Download Items for LAB 02
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/02%20SSIS%20Migration/02-SSIS%20Migration.zip?raw=true' -OutFile "$InstallPath\Lab2.zip"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$InstallPath\Lab2.zip" "$Labs2Path"

#Download Items for LAB 03
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/03%20Security/Hands-on-Lab%20-%20Data%20Security.pdf' -OutFile "$Labs3Path\Hands-on Lab - Security.pdf"
$StorageAccount | out-file -FilePath "$Labs3Path\StorageAccount.txt"

Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Hands-On%20Lab/03%20Security/SQLScripts/2.%20Auditing.sql' -OutFile "$Labs3SecurityPath\2.Auditing.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Hands-On%20Lab/03%20Security/SQLScripts/3.%20Dynamic%20Data%20Masking.sql' -OutFile "$Labs3SecurityPath\3.Dynamic Data Masking.sql"
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Hands-On%20Lab/03%20Security/SQLScripts/4.%20TDE%20and%20Password%20Reset.sql' -OutFile "$Labs3SecurityPath\4.TDE and Password Reset.sql"

#########################################################################
#Install Applications
#########################################################################

# Download and install SSDT
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2124518' -OutFile 'C:\Install\SSDT-Setup-ENU.exe'
Start-Process -file 'C:\Install\SSDT-Setup-ENU.exe' -arg '/layout c:\Install\vs_install_bits /quiet /log C:\Install\SSDTLayout_install.txt' -wait
start-sleep 10
Start-Process -file 'C:\Install\vs_install_bits\SSDT-Setup-enu.exe' -arg '/INSTALLVSSQL /install INSTALLALL /norestart /passive /log C:\Install\SSDT_install.txt' -wait 

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile "$InstallPath\DataMigrationAssistant.msi"
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru 

# Download Storage Explorer
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409' -OutFile "$InstallPath\StorageExplore.exe"
Start-Process -file 'C:\Install\StorageExplore.exe' -arg '/VERYSILENT /ALLUSERS /norestart /LOG C:\Install\StorageExplore_install.txt'

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2088649' -OutFile 'C:\Install\SSMS-Setup.exe'
start-sleep 5
#$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
#Invoke-Command -ScriptBlock $pathArgs 
Start-Process -file 'C:\Install\SSMS-Setup.exe' -arg '/passive /install /norestart /quiet /log C:\Install\SSMS_install.txt' -wait 


# Create Shortcut on desktop
$TargetFile   = "C:\_SQLHACK_\"
$ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
