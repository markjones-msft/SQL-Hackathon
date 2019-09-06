
#Login-AzAccount
Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SQL Server Migration Hack Build Script"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will build the enviroment for the SQL Server Hack and Labs"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"


Function Run-ARMTemplate 
{
    param (
        [string]$ResourceGroupName,
        [string]$TemplateUri,
        [string]$Name,
        [int]$vmCount,
        [string] $SharedResourceGroup,
        [string] $Wait

        )
        If (-not $vmCount)
         {
                $scriptBlock = {
                param ($ResourceGroupName,$TemplateUri,$Name)
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -Name $Name}

                if (-not $wait) 
                {
                    Start-Job -ScriptBlock $scriptBlock -ArgumentList @($ResourceGroupName,$TemplateUri,$Name,$SharedRG)}
                else
                {
                    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -Name $Name
                }
            }
        else 
        {
             $scriptBlock = {
                param ($ResourceGroupName,$TemplateUri,$Name, $SharedResourceGroup, $vmCount)
                New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -Name $Name -vmCount $vmCount -SharedResourceGroup $SharedResourceGroup}
            
                Start-Job -ScriptBlock $scriptBlock -ArgumentList @($ResourceGroupName,$TemplateUri,$Name, $SharedResourceGroup, $vmCount)
            
         }

}

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
    Write-Warning "Maximum number TEAM VM's is 20. Setting to 20 VM's"
    $TeamVMCount = 20

}

$DefaultValue = "NorthEurope"
if (($Location = Read-Host "Please enter the Location of the Resource Groups. (default value: $DefaultValue)") -eq '') {$Location = $DefaultValue}
If (“NorthEurope”,”WestEurope”,”UKSouth”, "UKWest" -NotContains $Location)
{
    Write-Warning "Unrecognised location. Setting to Default $DefaultValue"
    $Location = "NorthEurope"

}

$DefaultValue = "SQLHACK-SHARED"
if (($SharedRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$SharedRG = $DefaultValue}

# Check Resource Groups do not already exist
#Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
#if (!($notPresent)) {Write-Warning "Resource Group $SharedRG already exisits. Please check retry"; return;}

$DefaultValue = "SQLHACK-TEAM_VMs"
if (($TeamRG = Read-Host "Please Shared resource group name. (default value: $DefaultValue)") -eq '') {$TeamRG = $DefaultValue}

#Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
#if (!($notPresent)) {Write-Warning "Resource Group $TeamRG already exisits. Please check retry"; return;}

###################################################################
# Setup Hack Resource Groups
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating Subscriptions $SharedRG and $TeamRG.................................................."
New-AzResourceGroup -Name $SharedRG -Location $Location 
New-AzResourceGroup -Name $TeamRG -Location $Location


###################################################################
# Setup Network
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating Virtual Network................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20RC1.json"
Run-ARMTemplate -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "NetworkBuild" -Wait "True"

# Check if Vnet has been created
Get-AzVirtualNetwork -Name "$SharedRG-vnet" -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "VNET Failed to build. Please check and retry";return;}


###################################################################
# Setup Shared Resources
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating DMS, Datafactory, Keyvault, storage account shared resources.................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Shared%20-%20RC1.json"

Run-ARMTemplate  -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "SharedServicesBuild"

# Setup KeyVault
$Random = Get-Random -Maximum 99999
$Keyvault = "sqlhack-keyvault-$Random"
New-AzKeyVault -Name $Keyvault  -ResourceGroupName $SharedRG -Location $Location -EnableSoftDelete

Get-AzKeyVault -Name $Keyvault -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}


###################################################################
# Setup SQL Legacy Server
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating legacySQL2008 Server................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20LegacySQL-%20RC1.json"
Run-ARMTemplate  -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "LegacySQLBuild"


###################################################################
# Setup Team VM's
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating $TeamVMCount Team Server(s).................................................."
$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Jump%20Servers%20-%20RC1.json"
Run-ARMTemplate  -ResourceGroupName $TeamRG -TemplateUri $TemplateUri -Name "TeamVMBuild" -vmCount $TeamVMCount -SharedResourceGroup $SharedRG

#Create Blob Storage Container and SASURI Key.

###################################################################
# Setup Managed Instance
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating sqlhack-mi Managed Instance................................................."

$TemplateUri = "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Managed%20Instance-%20RC1.json"
Run-ARMTemplate  -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "ManagedInstanceBuild"

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Enviroment Build in progress. Please check RG deployments for errors."

Write-Warning "NOTE: THE FOLLOWING  POST BUILD TASKS ARE REQUIRED."
Write-Warning "1. DataFactory Build Ok. You will need to start the integration runtime and enable AHUB"
Write-Warning "2. Create SASURI Key to the Azure Blob Storage for Data Migration tasks"


