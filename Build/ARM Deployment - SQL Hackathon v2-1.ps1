
##########################################################################################################
# This script uses AZ powershell commands and the SQLServer library. if needed,  install the following 
##########################################################################################################
If ((Get-InstalledModule -Name Az -AllVersions)) {if ((read-host "This script uses AZ modules which seem to be missing. Do you wish to install now? (Y)es to accept, any other key to abort") -eq "Y") {Install-Module -Name Az -AllowClobber -Scope CurrentUser} else {write-host -BackgroundColor Black -ForegroundColor Red "This script will now terminate as AZ Modules not installed. Please see https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.1.0 " ; Return}}
If ((Get-InstalledModule -Name Az.sql -AllVersions)) {if ((read-host "This script uses Az.Sql modules which seem to be missing. Do you wish to install now? (Y)es to accept, any other key to abort") -eq "Y") {Import-Module -Name Az.sql -AllowClobber -Scope CurrentUser} else {write-host -BackgroundColor Black -ForegroundColor Red "This script will now terminate as SqlServer Modules not installed. Please see https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.1.0 " ; Return}}

Import-Module Az.Accounts
Import-Module Az.Sql

connect-AzAccount

#If you need to change subscriptions please use the below commands.
#Get-AzSubscription
Select-AzSubscription 153b9143-5efd-483a-a335-81bfb56591c0

Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SQL Server Migration Hack Build Script"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will build the enviroment for the SQL Server Hack and Labs"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Setting Enviroment Varibales....................................................."
$subscriptionID = (Get-AzContext).Subscription.id
$subscriptionName = (Get-AzContext).Subscription.Name

if(-not $subscriptionID) {   `
    $subscriptionMessage = "There is no selected Azure subscription. Please use Select-AzSubscription to select a default subscription";  `
    Write-Warning $subscriptionMessage ; return;}  `
else {   `
    $subscriptionMessage = ("Actually targeting Azure subscription: {0} - {1}." -f $subscriptionID, $subscriptionName)}
Write-Host -BackgroundColor Black -ForegroundColor Yellow $subscriptionMessage

###################################################################
# Setup Vaiables
###################################################################
$DefaultValue = 5
if (($TeamVMCount = Read-Host "Please enter the number of Team VM's required (1-20) (default value: $DefaultValue)") -eq '') {$TeamVMCount = $DefaultValue}
If ($TeamVMCount -gt 20)
{
    Write-Warning "Maximum number TEAM VM's is 20. Setting to 5 VM's"
    $TeamVMCount = 5

}

$DefaultValue = "NorthEurope"
if (($Location = Read-Host "Please enter the Location of the Resource Groups. (default value: $DefaultValue)") -eq '') {$Location = $DefaultValue}
If (“NorthEurope”,”WestEurope”,”UKSouth”, "UKWest", "WestUS", "EastUS" -NotContains $Location  ) {Write-Warning "Unrecognised location. Setting to Default $DefaultValue" ; $Location = "NorthEurope"}

Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: MAKE A NOTE OF THE FOLLOWING USERNAME and PASSWORD ########################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "The username and password specified next, will be used to credentials to SQL, Managed Instance and any VM's"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check username and retry..."; Exit};
    $adminUsername = Read-Host "Please enter an Admin username (more than 6 characters)"
    }
while ($adminUsername.length -le 6)


$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check password and retry..."; Exit};
    $Password = Read-Host "Please enter a 15 character Password. The password must be between 15 and 128 characters in length and must contain at least one number, one non-alphanumeric character, and one upper or lower case letter"
    }
while ($Password.length -le 15)
$adminPassword = convertTo-securestring $Password -AsPlainText

$DefaultValue = "SQLHACK-SHARED"
if (($SharedRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$SharedRG = $DefaultValue}

$DefaultValue = "SQLHACK-TEAM_VMs"
if (($TeamRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$TeamRG = $DefaultValue}

###################################################################
# Verify Setup
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################### IMPORTANT: CHECK THE FOLLOWING BEFORE CONTINUING ###########################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Target Subscription ID:`t`t`t`t $subscriptionID "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Target Subscription Name:`t`t`t $subscriptionName "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Target Region:`t`t`t`t`t $Location "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Target Resource Group for Shared resources:`t $SharedRG "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Target Resource Group for Team VM's:`t`t $TeamRG "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Number Team VM's to Build:`t`t`t $TeamVMCount "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Administrator UserName:`t`t`t`t $adminUsername "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Administrator Password:`t`t`t`t $Password "
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

if ((read-host "Please the above is correct. Press a to abort, any other key to continue.") -eq "a") {Return;}

###################################################################
# Setup Hack Resource Groups
###################################################################
$notPresent = Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {$notPresent = New-AzResourceGroup -Name $SharedRG -Location $Location} 

$notPresent =Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {$notPresent = New-AzResourceGroup -Name $TeamRG -Location $Location}

###################################################################
# Setup Network and Storage account
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Deploying Virtual Network................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20v2.json"
$NetworkBuild = New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "NetworkBuild"
$NetworkBuild = $NetworkBuild.ProvisioningState.ToString()

# Check if Vnet has been created
$notPresent = Get-AzVirtualNetwork -Name "$SharedRG-vnet" -ResourceGroupName $SharedRG -ErrorAction SilentlyContinue 
if (!($notPresent)) {Write-Warning "VNET Failed to build. Please check and retry";return;}

###################################################################
# Setup SASURI and copy backups to containers
###################################################################
#Create Blob Storage Container and SASURI Key.
$StorageAccount = (Get-AzStorageAccount -ResourceGroupName $SharedRG).StorageAccountName 
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $SharedRG -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0

$notPresent = New-AzStorageContainer -Context $Context -Name migration 
$notPresent = New-AzStorageContainer -Context $Context -Name auditlogs
$notPresent = New-AzStorageContainer -Context $Context -Name sqlbackups

$storagePolicyName = “Migration-Policy”
$expiryTime = (Get-Date).AddYears(1)
$notPresent = New-AzStorageContainerStoredAccessPolicy -Container migration -Policy $storagePolicyName -Permission rwl -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
$SASUri = (New-AzStorageContainerSASToken -Name "migration" -FullUri -Policy $storagePolicyName -Context $Context)
$JsonSASURI = $SASUri | ConvertTo-Json

# Copy files locally
Invoke-WebRequest 'https://github.com/markjones-msft/SQL-Hackathon/blob/master/Build/Database%20Build/LocalMasterDataDb.bak?raw=true' -OutFile "$env:temp\LocalMasterDataDb.bak" | Wait-Process
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/3-%20RESTORE%20FIXES.sql' -OutFile "$BackupPath\3- RESTORE FIXES.sql" | Wait-Process
Invoke-WebRequest 'https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/Database%20Build/4-DROP%20DATABASES.sql' -OutFile "$BackupPath\4-DROP DATABASES.sql" | Wait-Process


write-host %temp%
$SASUri = (New-AzStorageContainerSASToken -Name "sqlbackups" -FullUri -Policy $storagePolicyName -Context $Context)
$FileToUpload = "$env:temp\LocalMasterDataDb.bak"

Set-AzStorageBlobContent  -Container "sqlbackups" -File $FileToUpload -Blob "LocalMasterDataDb.bak" -context $Context


###################################################################
# Setup SQL Legacy Server
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Deploying legacySQL2008 Server................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20LegacySQL-%20v2.json"
$LegacySQLBuild = New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $adminpassword -adminUsername $adminUsername -Name "LegacySQLBuild" -AsJob 
$LegacySQLBuild = $LegacySQLBuild.State.ToString()

###################################################################
# Setup Data Migration Service, Gateway, Keyvault
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Deploying DMS, Datafactory, Keyvault, storage account shared resources.................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Shared%20-%20v2.json"
$SharedServicesBuild = New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "SharedServicesBuild" -AsJob 
$SharedServicesBuild = $SharedServicesBuild.State.ToString()

# Setup KeyVault
$Random = Get-Random -Maximum 99999
$Keyvault = "sqlhack-keyvault-$Random"
$notPresent = New-AzKeyVault -Name $Keyvault  -ResourceGroupName $SharedRG -Location $Location -EnableSoftDelete 

$notPresent = Get-AzKeyVault -Name $Keyvault -ResourceGroupName $SharedRG -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}

###################################################################
# Setup Team VM's
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Deploying $TeamVMCount Team Server(s).................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Jump%20Servers%20-%20v2.json"
$TeamVMBuild = New-AzResourceGroupDeployment -ResourceGroupName $TeamRG -TemplateUri $TemplateUri -Name "TeamVMBuild" -vmCount $TeamVMCount -SharedResourceGroup $SharedRG -SASURIKey $JsonSASURI -StorageAccount $StorageAccount -adminPassword $adminpassword -adminUsername $adminUsername -AsJob 
$TeamVMBuild = $TeamVMBuild.State.ToString()

###################################################################
# Setup Managed Instance and ADF with SSIS IR
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Deploying sqlhack-mi Managed Instance................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Managed%20Instance-%20v2.json"
$ManagedInstanceBuild = New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $adminpassword -adminUsername $adminUsername -location $location -createNSG 1 -createRT 1 -Name "ManagedInstanceBuild" -AsJob
$ManagedInstanceBuild = $ManagedInstanceBuild.State.ToString()

##################################################################
# VERIFY BUILD
##################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SQL Hack Build in progress. Checking status of build..."
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Please note this can take up to 5 hours to complete, but please leave script running to allow for Post build tasks to complete."

[int]$NetworkBuildStatus = 0
[int]$LegacySQLBuildStatus = 0
[int]$SharedServicesBuildstatus = 0
[int]$TeamVMBuildStatus = 0
[int]$ManagedInstanceBuildStatus = 0
[int]$Components = 0
[int]$Seconds = 0
[int] $y = 29

If ($NetworkBuild){$Components ++}; If ($LegacySQLBuild){$Components ++};If ($SharedServicesBuild){$Components ++};If ($TeamVMBuild){$Components ++};If ($ManagedInstanceBuild){$Components ++}
If ($NetworkBuild){$Seconds = 60}; If ($LegacySQLBuild){$Seconds = 600};If ($SharedServicesBuild){$Seconds = 1200};If ($TeamVMBuild){$Seconds = 1800};If ($ManagedInstanceBuild){$Seconds = 18000}

write-host -BackgroundColor Black -ForegroundColor Yellow "###################################################################"
write-host -BackgroundColor Black -ForegroundColor Yellow "Checking Build Status every 30 Seconds."
write-host -BackgroundColor Black -ForegroundColor Yellow "###################################################################"

do 
{
    $y += 1
    $Seconds = $Seconds -1
    start-sleep -s 1 
    Write-Progress -Activity "Build Progress" -Status "Estimated time remianing:" -SecondsRemaining $Seconds

    If ($y -eq 30)
    {
       $y=0
               
        #Check Status Network Build
        If ($NetworkBuild)
        {   $Status = Get-AzResourceGroupDeployment -ResourceGroupName $SharedRG -Name "NetworkBuild" -ErrorAction SilentlyContinue ; if ($Status) {$Status = $Status.ProvisioningState.Trim()}
            If ($NetworkBuildStatus -eq 0) { switch ($Status) { "Failed" {Write-Host -BackgroundColor Black -ForegroundColor Red "Network Build Status: $Status"; $NetworkBuildStatus=1} "Succeeded" {Write-Host -BackgroundColor Black -ForegroundColor Green "Network Build Status: $Status"; $NetworkBuildStatus=1} } }
        }

        #Check Status Legacy SQL Build
        If ($LegacySQLBuild)
        {    $Status = Get-AzResourceGroupDeployment -ResourceGroupName $SharedRG -Name "LegacySQLBuild" -ErrorAction SilentlyContinue ; if ($Status) {$Status = $Status.ProvisioningState.Trim()}
            If ($LegacySQLBuildStatus -eq 0) { switch ($Status) { "Failed" {Write-Host -BackgroundColor Black -ForegroundColor Red "Legacy SQL Build Status: $Status"; $LegacySQLBuildStatus=1} "Succeeded" {Write-Host -BackgroundColor Black -ForegroundColor Green "Legacy SQL Build Status: $Status"; $LegacySQLBuildStatus=1} } }
        }

        #Check Status Shared Services Build
        If ($SharedServicesBuild)
        {   $Status = Get-AzResourceGroupDeployment -ResourceGroupName $SharedRG -Name "SharedServicesBuild" -ErrorAction SilentlyContinue ; if ($Status) {$Status = $Status.ProvisioningState.Trim()}
        If ($SharedServicesBuildstatus -eq 0) { switch ($Status) { "Failed" {Write-Host -BackgroundColor Black -ForegroundColor Red "Shared Services Build Status: $Status"; $SharedServicesBuildstatus=1} "Succeeded" {Write-Host -BackgroundColor Black -ForegroundColor Green "Shared Services Build Status: $Status"; $SharedServicesBuildstatus=1} } }
        }

        #Check Status TeamVM Build
        If ($TeamVMBuild)
        {  $Status = Get-AzResourceGroupDeployment -ResourceGroupName $TeamRG -Name "TeamVMBuild" -ErrorAction SilentlyContinue ; if ($Status) {$Status = $Status.ProvisioningState.Trim()}
            If ($TeamVMBuildStatus -eq 0) { switch ($Status) { "Failed" {Write-Host -BackgroundColor Black -ForegroundColor Red "Team VM Build Build Status: $Status"; $TeamVMBuildStatus=1} "Succeeded" {Write-Host -BackgroundColor Black -ForegroundColor Green "Team VM Build Build Status: $Status"; $TeamVMBuildStatus=1} } }
        }

        #Check Status Managed Instance Build
        if ($ManagedInstanceBuild)
        {
            $Status = Get-AzResourceGroupDeployment -ResourceGroupName $SharedRG -Name "ManagedInstanceBuild" -ErrorAction SilentlyContinue ; if ($Status) {$Status = $Status.ProvisioningState.Trim()}
        If ($ManagedInstanceBuildStatus -eq 0) { switch ($Status) 
                { 
                    "Failed" {Write-Host -BackgroundColor Black -ForegroundColor Red "Managed Instance Build Status: $Status"; $ManagedInstanceBuildStatus = 1} 
                    "Succeeded" 
                    {   Write-Host -BackgroundColor Black -ForegroundColor Green "Managed Instance Build Status: $Status"; $ManagedInstanceBuildStatus = 1
                
                        ## POST BUILD SCRIPT HERE
                        $MIDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $SharedRG -Name "ManagedInstanceBuild" -ErrorAction SilentlyContinue
                        $ManagedInstanceName = $MIDeployment.Outputs.item("resourceID").value.ToString()
                        
                        $ManagedInstance = Get-AzSqlInstance -ResourceGroupName $SharedRG -Name $ManagedInstanceName

                        write-host $ManagedInstance.FullyQualifiedDomainName

                        Restore-AzSqlInstanceDatabase 

                    } 
                } 
            }
        }
    }
}
While (($NetworkBuildStatus + $LegacySQLBuildStatus + $TeamVMBuildStatus + $SharedServicesBuildstatus + $ManagedInstanceBuildStatus) -ne $Components)

Write-host ($NetworkBuildStatus + $LegacySQLBuildStatus + $TeamVMBuildStatus + $SharedServicesBuildstatus + $ManagedInstanceBuildStatus)
Write-Host -BackgroundColor Black -ForegroundColor Green "SQL Hack build Complete"

Write-Host -BackgroundColor Black -ForegroundColor Yellow  "NOTE: THE FOLLOWING  POST BUILD TASKS ARE REQUIRED."
Write-Host -BackgroundColor Black -ForegroundColor Yellow  "1. DataFactory: You will need to start the integration runtime and enable AHUB"
Write-Host -BackgroundColor Black -ForegroundColor Yellow  "2. COPY the SASURI Key tas this will be needed for the Data Migration tasks"
Write-Host -BackgroundColor Black -ForegroundColor Yellow  "3. All labs and documaention can be found on TEAMVM's in C:\_SQLHACK_\LABS"
Write-Host -BackgroundColor Black -ForegroundColor Yellow  "4. Ensure the Script SQLMI-PostCreate.sql script is run on the Managed Instance before runnign the lab"
