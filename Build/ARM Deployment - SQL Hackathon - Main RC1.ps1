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

$SharedRG = "SQLHACK-SHARED"
$TeamRG = "SQLHACK-TEAM_VMs"
#$ResourcesRG = "SQLHACK-RESOURCES"

$Location = "NorthEurope"

# Check Resource Groups do not already exist
Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "Resource Group $SharedRG already exisits. Please check retry"; return;}

Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {Write-Warning "Resource Group $TeamRG already exisits. Please check retry"; return;}
Get-AzResourceGroup -

New-AzResourceGroup -Name $SharedRG -Location $Location
New-AzResourceGroup -Name $TeamRG -Location $Location


###################################################################
# Setup Network
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG `
-TemplateFile "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20RC1.json" `
-Name "NetworkBuild"

# Check if Vnet has been created
Get-AzVirtualNetwork -Name SQLHACK-SHARED-vnet -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "VNET Failed to build. Please check and retry";return;}

###################################################################
# 1.Setup Shared Resources
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName "SQLHACK-SHARED" `
-TemplateFile "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Shared%20-%20v2.0.json" `
-Name "SQLLegacyBuild"

#TODO Check Resources Build ok here

Write-Warning "DataFactory Build Ok. You will need to start the integration runtime and enable AHUB"

# Setup KeyVault 
New-AzKeyVault -Name sqlhack-keyvault -ResourceGroupName $SharedRG -Location $Location -EnableSoftDelete

Get-AzKeyVault -Name sqlhack-keyvault -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}


$TeamVMCount = 01

###################################################################
# 2. Setup Team Workstations
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $TeamRG `
-TemplateFile "https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/Build/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Jump%20Servers%20-%20v2.5.json" `
-Name "TeamVMBuild" `
-vmCount $TeamVMCount

