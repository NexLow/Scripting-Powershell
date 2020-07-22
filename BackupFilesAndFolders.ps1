# This script is in WIP
function CreateArchiveFilename {
    [String]$Date = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
    [String]$Time = Get-Date -UFormat %H-%M
    [String]$FileName = $Date + "_" + $Time + "_test"
    Write-Host "$FileName"
}

function Main {
    CreateArchiveFilename
    
}

# Run the script
Main