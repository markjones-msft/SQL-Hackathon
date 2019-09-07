param (
    [string]$MIName, 
    [string]$FilePath
)

$MIName | out-file -FilePath "$FilePath\Managed Instance FDQN.txt"