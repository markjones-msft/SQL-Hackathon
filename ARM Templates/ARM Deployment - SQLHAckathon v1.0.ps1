#Login-AzAccount


###################################################################
# Setup Hack Resource Groups
###################################################################

$SharedRG = "SQLHACK-SHARED"
$TeamRG = "SQLHACK-TEAM_VMs"
$Location = "NorthEurope"

New-AzResourceGroup -Name $SharedRG -Location $Location
New-AzResourceGroup -Name $TeamRG -Location $Location

###################################################################
# Setup Network
###################################################################
New-AzResourceGroupDeployment `
-ResourceGroupName $SharedRG `
-TemplateUri https://raw.githubusercontent.com/markjones-msft/SQL-Hackathon/master/ARM%20Templates/ARM%20Template%20-%20SQL%20Hackathon%20-%20Network%20-%20v1.0.json
