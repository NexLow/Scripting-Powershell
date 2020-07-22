# This script is in WIP
function CreateArchiveFilename {
    [String]$date = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
    [String]$time = Get-Date -UFormat %H-%M
}

function Main {
    CreateArchiveFilename
    
}

# Run the script
Main