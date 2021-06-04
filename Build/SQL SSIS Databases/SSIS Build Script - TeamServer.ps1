

Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: SSIS LAB BULD SCRIPT ######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will setup and install the SSIS Lab Databases."
Write-Host -BackgroundColor Black -ForegroundColor Yellow "IMPORTANT: Please only run after the build is complete"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

###############################################################################
# Set up and install AZ and SQL Modules used by this script
###############################################################################

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Checking and Installing Az and SQL modules......................................."


Set-ExecutionPolicy RemoteSigned -Force

If(-not(Get-InstalledModule Az -ErrorAction silentlycontinue)){
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

If(-not(Get-InstalledModule SQLServer -ErrorAction silentlycontinue)){
    Install-Module SQLServer -Confirm:$False -Repository PSGallery -Force
}

###############################################################################
# Connect to Azure with Subscription and Tenant
###############################################################################

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Connecting Powershell to your Subscription......................................."
Connect-AzAccount 

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Setting Enviroment Varibales....................................................."
$subscriptionID = (Get-AzContext).Subscription.id
$subscriptionName = (Get-AzContext).Subscription.Name

if(-not $subscriptionID) {   `
    $subscriptionMessage = "There is no selected Azure subscription. Please use Select-AzSubscription to select a default subscription";  `
    Write-Warning $subscriptionMessage ; return;}  `
else {   `
    $subscriptionMessage = ("Targeting Azure subscription: {0} - {1}." -f $subscriptionID, $subscriptionName)}
Write-Host -BackgroundColor Black -ForegroundColor Yellow $subscriptionMessage

if ((read-host "Please ensure this is the correct subscription. Press a to abort, any other key to continue.") -eq "a") {Return;}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Continuing to build.................................................."

###############################################################################
# Set Variables
##############################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "################################# BUILD ENVIROMENT #########################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Please Enter the Admin username, password and SHARED resource groups used in the Build"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"
$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check username and retry..."; Exit};
    $adminUsername = Read-Host "Please enter the Admin Username used within the Build (default value: DemoUser)"
    }
while ($adminUsername.length -le 6)

$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check password and retry..."; Exit};
    $adminPassword = Read-Host "Please enter the Admin password used within the Build" -AsSecureString
    }
while ($adminPassword.length -le 15)

$DefaultValue = "SQLHACK-SHARED"
if (($SharedRG = Read-Host "Please enter the SHARED resource group name. (default value: $DefaultValue)") -eq '') {$SharedRG = $DefaultValue}

$notPresent = Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "Could not find SHARED resource group. Please check and retry";return;}

###############################################################################
# Find Managed Instance
###############################################################################
$sqlmiFDQN = (Get-AzSqlInstance -ResourceGroupName $SharedRG).FullyQualifiedDomainName  | Select-object -First 1

if ($sqlmiFDQN -eq $null) {Write-Host -BackgroundColor Red -ForegroundColor White "Managed Instance not found. Please check build to ensure all deployments have completed and retry. Aborting" ; Return;}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Found and targeting Managed Instance: $sqlmiFDQN"

if ((read-host "Please ensure this is the correct Managed Instance. Press a to abort, any other key to continue.") -eq "a") {Return;}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Continuing to build.................................................."


###############################################################################
# Setup Storage Account
###############################################################################

# First find and setup the Storage acocunt

# Setup Storage Conext
$StorageAccount = (get-AzStorageAccount -ResourceGroupName "SQLHACK-SHARED").StorageAccountName  | Select-object -First 1
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName "SQLHACK-SHARED" -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0

#Create Container Build
If(-not (Get-AzStorageContainer -Context $Context -Name build -ErrorAction Ignore)){
    $output = New-AzStorageContainer -Context $Context -Name build
}

#Create SASUri for Build Container
$storagePolicyName = “Build-Policy”
$expiryTime = (Get-Date).AddYears(1)

If(-not (Get-AzStorageContainerStoredAccessPolicy -Context $Context -Name build)){
    New-AzStorageContainerStoredAccessPolicy -Container build -Policy $storagePolicyName -Permission rwld -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
}
$SASUri = (New-AzStorageContainerSASToken -Name "build" -FullUri -Policy $storagePolicyName -Context $Context)

#Copy Files from github to Local machine
$Temp = (Get-Item -Path Env:Temp).value + "\SQLHACK"
$output = md $Temp -ErrorAction Ignore

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Copying Backups to Blob storage....................................................."

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/SQL%20SSIS%20Databases/2008DW.bak?raw=true' -UseBasicParsing -OutFile "$temp\2008DW.bak" | Wait-Process
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/SQL%20SSIS%20Databases/LocalMasterDataDb.bak?raw=true' -UseBasicParsing -OutFile "$temp\LocalMasterDataDb.bak" | Wait-Process
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/SQL%20SSIS%20Databases/SharedMasterDataDB.bak?raw=true' -UseBasicParsing -OutFile "$temp\SharedMasterDataDB.bak" | Wait-Process
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/SQL%20SSIS%20Databases/TenantDataDb.bak?raw=true' -UseBasicParsing -OutFile "$temp\TenantDataDb.bak" | Wait-Process

# Copy Files to Blob
cd $Temp
$output = Get-ChildItem -File -Recurse -Filter "*.bak" |  Set-AzStorageBlobContent -Container "build" -Context $Context -Force

###############################################################################
# Restore Databases
###############################################################################
$Credentials = New-Object PSCredential $adminUsername, $adminPassword

Write-Host -BackgroundColor Black -ForegroundColor Yellow "################################# RESTOING DATABASES #######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SSIS Databases will be restored and CLR will be enabled on the Managed Instance"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

# Set SQL MI CLR
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting to enable CLR on the Managed Instance $sqlmiFDQN"
$Query = "EXEC sp_configure ""CLR Enabled"", 1; RECONFIGURE WITH OVERRIDE"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Set SQL MI Credential
$Query = "if not exists (select 1 from sys.credentials where name = '" + $SASUri.split('?')[0,2] + "') CREATE CREDENTIAL [" + $SASUri.split('?')[0,2] + "] WITH IDENTITY='Shared Access Signature', SECRET='" + $SASUri.split('?')[1,2] + "'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password

# Restore Database 2008DW
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore 2008DW database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob '2008DW.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = '2008DW') RESTORE DATABASE [2008DW] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Restore Database LocalMasterDataDb
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore LocalMasterDataDb database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'LocalMasterDataDb.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = 'LocalMasterDataDb') RESTORE DATABASE [LocalMasterDataDb] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Restore Database SharedMasterDataDB
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore SharedMasterDataDB database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'SharedMasterDataDB.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = 'SharedMasterDataDB') RESTORE DATABASE [SharedMasterDataDB] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Restore Database TenantDataDb
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore TenantDataDb database on Managed Instance $sqlmiFDQN"
$blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'TenantDataDb.bak').ICloudBlob.Uri.AbsoluteUri
$Query = "if not exists (select 1 from sysdatabases where name = 'TenantDataDb') RESTORE DATABASE [TenantDataDb] FROM URL = '$blob'"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Cleanup Credential used on SQLMI
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Cleaning Up........."

del "*.bak"
Remove-AzStorageContainer -Context $Context -Name build -Force
$Query = "DROP CREDENTIAL [" + $SASUri.split('?')[0,2] + "]"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password


Write-Host -BackgroundColor Black -ForegroundColor Yellow "Databases Restored. Please Check databases 2008DW, LocalMasterDB, SharedMaterDB and TenantDataDB are present on the SQL MI"
