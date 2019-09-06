param (
    [string]$SASURIKey , 
    [string]$StorageAccount
)

$InstallPath = 'C:\Install'
$LabsPath = 'C:\_SQLHACK_\LABS'
$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data Migration'
$Labs2Path = 'C:\_SQLHACK_\LABS\02-SSIS Migration'
$Labs3Path = 'C:\_SQLHACK_\LABS\03-Security'

#Create Folders for Labs and Installs
md -Path $LabsPath
md -Path $InstallPath
md -Path $Labs1Path
md -Path $Labs2Path
md -Path $Labs3Path


#Download Items for LAB 01
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20LAB%20-%20Data%20Migration/SQLHACK%20-%20DB%20Migration%20LAB%20and%20Parameters.docx?raw=true' -OutFile "$Labs1Path\Hands-on Lab - Data Migration.docx"
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/01%20LAB%20-%20Data%20Migration/SimpleTranReportApp.exe?raw=true' -OutFile "$Labs1Path\SimpleTranReportApp.exe"

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
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Hands-On%20Lab/03%20Security/Hands-on-Lab%20-%20Data%20Security.docx?raw=truee' -OutFile "$InstallPath\Hands-on Lab - Security.docx"
$StorageAccount | out-file -FilePath "$Labs3Path\StorageAccount.txt"


# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2088649' -OutFile 'C:\Install\SSMS-Setup.exe'
$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
Invoke-Command -ScriptBlock $pathArgs 

# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile "$InstallPath\DataMigrationAssistant.msi"
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru 


# Download and install SSDT
Invoke-WebRequest 'https://aka.ms/vs/15/release/vs_sql.exe' -OutFile "$InstallPath\vs_sql.exe" 
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2095463' -OutFile 'C:\Install\SSDT-Setup-ENU.exe' 

#Start-Process -file 'C:\Install\vs_sql.exe' -arg '--layout c:\install\vs_install_bits --lang en-us --quiet --log C:\Install\VSLayout_install.txt' | Out-Null
Start-Process -file 'C:\Install\SSDT-Setup-ENU.exe' -arg '/layout c:\Install\vs_install_bits /quiet /log C:\Install\SSDTLayout_install.txt' -wait -NoNewWindow

#Start-Process -file 'C:\Install\vs_install_bits\vs_setup.exe' -arg '--noweb --quiet' -wait
Start-Process -file 'C:\Install\vs_install_bits\SSDT-Setup-enu.exe' -arg '/install INSTALLIS /quiet /norestart /log C:\Install\SSDT_install.txt' -NoNewWindow

# Create Shortcut on desktop
$TargetFile   = "C:\_SQLHACK_\"
$ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
