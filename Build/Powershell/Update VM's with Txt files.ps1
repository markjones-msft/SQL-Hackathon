#Login-AzAccount

$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data_Migration\ManagedInstanceFDQN.txt'
$TeamRG = "SQLHACK-TEAM_VMs"
$MIName = "sqlhackmi-ozolxcelx6qfg.23c82fd56c8a.database.windows.net"
$Script = 'C:\Code\MIPathUpdate.ps1'
$VWMName = "vm-TEAM20"

$servers = Get-AzResource -ResourceGroupName $TeamRG -ResourceType Microsoft.Compute/virtualMachines

ForEach ($Server in $servers)
{
    Write-host $Server.Name
    $VWMName = $Server.Name
    
    Invoke-AzVMRunCommand -ResourceGroupName $TeamRG -Name $VWMName -CommandId RunPowerShellScript -ScriptPath $Script -Parameter @{MIName = "$MIName"; FilePath = "$Labs1Path"}

}

