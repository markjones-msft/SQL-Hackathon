
#connect-AzAccount
#Get-AzSubscription
#Select-AzSubscription <subscription ID here>


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

if (($response = read-host "Please ensure this is the correct subscription. Press a to abort, any other key to continue.") -eq "a") {Return;}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Continuing to build.................................................."

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

$DefaultValue = "SQLHACK-SHARED"
if (($SharedRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$SharedRG = $DefaultValue}

###################################################################
# Setup Hack Resource Groups
###################################################################
$notPresent = Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {New-AzResourceGroup -Name $SharedRG -Location $Location} 

$DefaultValue = "SQLHACK-TEAM_VMs"
if (($TeamRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$TeamRG = $DefaultValue}

$notPresent =Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {New-AzResourceGroup -Name $TeamRG -Location $Location}

$x = 3
do
    {$Password = Read-Host "Please enter the 16 character Password. This will be used in all SQL and VM logins" -AsSecureString
    ; $x = $x - 1; write-host "Number retries remaining: " $x;
    if ($x -le 0) {write-host "Existing build. Please check password and retry..."; Exit};
    }
while ($Password.length -le 16)
$adminPassword = convertto-securestring (convertfrom-securestring $Password)

###################################################################
# Setup Network and Storage account
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating Virtual Network................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20v2.json"
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "NetworkBuild" 

# Check if Vnet has been created
Get-AzVirtualNetwork -Name "$SharedRG-vnet" -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "VNET Failed to build. Please check and retry";return;}

###################################################################
# Setup SASURI
###################################################################
#Create Blob Storage Container and SASURI Key.
$StorageAccount = (get-AzStorageAccount -ResourceGroupName $SharedRG).StorageAccountName 
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $SharedRG -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0

New-AzStorageContainer -Context $Context -Name migration1
New-AzStorageContainer -Context $Context -Name auditlogs1

$storagePolicyName = “Migration-Policy1”
$expiryTime = (Get-Date).AddYears(1)
New-AzStorageContainerStoredAccessPolicy -Container migration -Policy $storagePolicyName -Permission rwl -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
$SASUri = (New-AzStorageContainerSASToken -Name "migration" -FullUri -Policy $storagePolicyName -Context $Context)

Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: PLEASE COPY THE FOLLOWING SASURI TOKEN ####################"
Write-host -BackgroundColor Black -ForegroundColor Yellow $SASUri
Write-host -BackgroundColor Black -ForegroundColor Yellow "Storage account name: $StorageAccount"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################"

read-host "Please Copy SASURI Key. Press any key to continue."
$JsonSASURI = $SASUri | ConvertTo-Json

###################################################################
# Setup SQL Legacy Server
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating legacySQL2008 Server................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20LegacySQL-%20v2.json"
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $adminPassword -Name "LegacySQLBuild" -AsJob 

###################################################################
# Setup Data Migration Service, Gateway, Keyvault
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating DMS, Datafactory, Keyvault, storage account shared resources.................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Shared%20-%20v2.json"

New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "SharedServicesBuild" -AsJob 

# Setup KeyVault
$Random = Get-Random -Maximum 99999
$Keyvault = "sqlhack-keyvault-$Random"
New-AzKeyVault -Name $Keyvault  -ResourceGroupName $SharedRG -Location $Location -EnableSoftDelete

Get-AzKeyVault -Name $Keyvault -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}


###################################################################
# Setup Team VM's
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating $TeamVMCount Team Server(s).................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Jump%20Servers%20-%20v2.json"

New-AzResourceGroupDeployment -ResourceGroupName $TeamRG -TemplateUri $TemplateUri -Name "TeamVMBuild" -vmCount $TeamVMCount -SharedResourceGroup $SharedRG -SASURIKey $JsonSASURI -StorageAccount $StorageAccount -adminPassword $Password -AsJob 

###################################################################
# Setup Managed Instance and ADF with SSIS IR
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating sqlhack-mi Managed Instance................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Managed%20Instance-%20v2.json"
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $Password -location $location -createNSG 1 -createRT 1 -Name "ManagedInstanceBuild" -AsJob

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Enviroment Build in progress. Please check RG deployments for errors."

Write-Warning "NOTE: THE FOLLOWING  POST BUILD TASKS ARE REQUIRED."
Write-Warning "1. DataFactory Build Ok. You will need to start the integration runtime and enable AHUB"
Write-Warning "2. COPY the SASURI Key tas this will be needed for the Data Migration tasks"

