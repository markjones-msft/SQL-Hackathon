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

#Create Folders for Labs and Installs
md -Path 'C:\SQLHACK'
md -Path 'C:\Install'
md -Path 'C:\SQLHACK\LABS'
md -Path 'C:\SQLHACK\LABS\01-Data Migration'
md -Path 'C:\SQLHACK\LABS\02-SSIS Migration'
md -Path 'C:\SQLHACK\LABS\03-Security'

# Download and install SQL Server Management Studio
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2088649' -OutFile 'C:\Install\SSMS-Setup.exe'
$pathArgs = {C:\Install\SSMS-Setup.exe /S /v/qn}
Invoke-Command -ScriptBlock $pathArgs


# Download and install Data Mirgation Assistant
Invoke-WebRequest 'https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi' -OutFile 'C:\Install\DataMigrationAssistant.msi'
Start-Process -file 'C:\Install\DataMigrationAssistant.msi' -arg '/qn /l*v C:\Install\dma_install.txt' -passthru | wait-process


# Download and install SSDT
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2095463' -OutFile 'C:\SSDT-Setup-ENU.exe'
$pathArgs = {C:\SSDT-Setup-ENU.exe /S /v/qn}
Invoke-Command -ScriptBlock $pathArgs








