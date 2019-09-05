[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$SubscriptionId,
   [int]$TeamVMCount
)

#Login-AzAccount

Select-AzSubscription -SubscriptionId $SubscriptionId

###################################################################
# Setup Hack Resource Groups
###################################################################

$SharedRG = "SQLHACK-SHARED1"
$TeamRG = "SQLHACK-TEAM_VMs1"
$Location = "NorthEurope"

# Check Resource Groups do not already exist
Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "Resource Group $SharedRG already exisits. Please check retry"; return;}

Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "Resource Group $TeamRG already exisits. Please check retry"; return;}

New-AzResourceGroup -Name $SharedRG -Location $Location 
New-AzResourceGroup -Name $TeamRG -Location $Location


###################################################################
# 1.Setup Network
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG `
-TemplateUri "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20RC1.json" `
-Name "NetworkBuild"

# Check if Vnet has been created
Get-AzVirtualNetwork -Name SQLHACK-SHARED-vnet -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "VNET Failed to build. Please check and retry";return;}


###################################################################
# 2.Setup SQL Legacy Server
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG
-TemplateUri "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20LegacySQL-%20RC1.json" `
-Name "LegacySQLBuild"

###################################################################
# 3.Setup Team VM's
###################################################################
$TeamVMCount = 01

New-AzResourceGroupDeployment `
-ResourceGroupName $TeamRG `
-TemplateUri "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Jump%20Servers%20-%20RC1.json" `
-Name "TeamVMBuild" `
-vmCount $TeamVMCount

###################################################################
# 4.Setup Shared Resources
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG
-TemplateUri "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Shared%20-%20RC1.json" `
-Name "SharedServicesBuild"

#TODO Check Resources Build ok here

Write-Warning "DataFactory Build Ok. You will need to start the integration runtime and enable AHUB"

# Setup KeyVault 
New-AzKeyVault -Name sqlhack-keyvault -ResourceGroupName $SharedRG -Location $Location -EnableSoftDelete

Get-AzKeyVault -Name sqlhack-keyvault -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}


###################################################################
# 5.Setup Managed Instance
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG
-TemplateUri "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Managed%20Instance-%20RC1.json" `
-Name "ManagedInstanceBuild"


