#Login-AzAccount

$Labs1Path = 'C:\_SQLHACK_\LABS\01-Data_Migration\ManagedInstanceFDQN.txt'
$TeamRG = "SQLHACK-TEAM_VMs"
$MIName = "sqlhackmi-ozolxcelx6qfg.23c82fd56c8a.database.windows.net"
$Script = 'C:\Code\CheckSQLStatus.ps1'
$VWMName = "vm-TEAM20"

$Servers = (get-azvm)

ForEach ($Server in $Servers)
{
    Write-host $Server.Name
    If ($server.name -like  "*sql*") 
        {
            Write-host -BackgroundColor Black -ForegroundColor Yellow "The server """ $server.Name """contains the word SQL in its name."
            if (($response = Read-host "Would you like to proceed and check if SQL is Installed on """ $server.Name """. (Press Y to Check for SQL Registry, N continue.") -eq "Y") 
                {
                
                
                # Test for Registry Path
                $Status= Invoke-AzVMRunCommand -ResourceGroupName $Server.ResourceGroupName -Name $Server.Name -CommandId RunPowerShellScript -ScriptPath $Script 
                write-host $Server.Name "SQL Installed: " $Status.value.message
                                
                }


        }

}

    ##$VWMName = $Server.Name
    
    ##Invoke-AzVMRunCommand -ResourceGroupName $TeamRG -Name $VWMName -CommandId RunPowerShellScript -ScriptPath $Script -Parameter @{MIName = "$MIName"; FilePath = "$Labs1Path"}

$VWMName = "legacysql2008"
$TeamRG = "SQLHACK-SHARED"

$TeamRG = "SQLHACK-TEAM_VMs"
$VWMName = "vm-TEAM20"

$Status= Invoke-AzVMRunCommand -ResourceGroupName $TeamRG -Name $VWMName -CommandId RunPowerShellScript -ScriptPath $Script 

write-host $object

write-host $Status.value.message


