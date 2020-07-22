# This script is in WIP

<#
.SYNOPSIS
Backup Files and Folders
#>

$ErrorActionPreference = 'Inquire'

function CorrectRewritingOfVariables {
    # Correct rewriting and checking if $FolderToBackup is valid
    If (($FolderToBackup -eq "") -or ($FolderToBackup -match " ") -or ($FolderToBackup -match '^\\') -or ($FolderToBackup -match '^.\\')) {
        Write-Host -Object 'Please, enter a valid absolute path for the variable "$FolderToBackup" and try again.' -ForegroundColor Red
        Exit
    } elseif ($FolderToBackup -notmatch '\\$') {
        [Int]$LengthFolderToBackup = $FolderToBackup.Length
        $FolderToBackup = $FolderToBackup.Insert($LengthFolderToBackup,"\")
    }

    # Correct rewriting and checking if $BackupDestination is valid
    If (($BackupDestination -eq "") -or ($BackupDestination -match " ") -or ($BackupDestination -match '^\\') -or ($BackupDestination -match '^.\\')) {
        Write-Host -Object 'Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
        Exit
    } elseif ($BackupDestination -notmatch '\\$') {
        [Int]$LengthBackupDestination = $BackupDestination.Length
        $BackupDestination = $BackupDestination.Insert($LengthBackupDestination,"\")
    }
}
function AreNotTheSame {
    # Verification if the $BackupDestination is the same as $FolderToBackup
    If ($BackupDestination -eq $FolderToBackup) {
        Write-Host -Object 'The folder $BackupDestination is the same as $FolderToBackup. Please do not put the same.' -ForegroundColor Red
        Exit
    }
}

function VerifyFolderToBackup {
    Write-Host -Object "=================================================="
    Write-Host -Object "      Verification of the folder to backup"
    Write-Host -Object "=================================================="

    Write-Host "Verification of the existence of the folder : " -NoNewline
    If (Test-Path -Path $FolderToBackup) {
        Write-Host -Object "The folder `"$FolderToBackup`" exist" -ForegroundColor Green 
    } Else {
        Write-Host -Object "The folder `"$FolderToBackup`" does not exist" -ForegroundColor Red
        Break
    }

}

function VerifyBackupDestination {
    Write-Host -Object "=================================================="
    Write-Host -Object "  Verification of the destination backup folder"
    Write-Host -Object "=================================================="

    Write-Host "Verification of the existence of the folder : " -NoNewline
    If (Test-Path -Path $BackupDestination) {
        Write-Host -Object "The folder `"$BackupDestination`" exist." -ForegroundColor Green 
    } Else {
        Write-Host -Object "The folder `"$BackupDestination`" does not exist." -ForegroundColor Red
        do {
            $CreateBackupDestination = Read-Host -Prompt "Do you want to create `"$BackupDestination`" (yes,no) ? "
            switch ($CreateBackupDestination.ToLower()) {
                "yes" { 
                    Write-Host -Object "Creating the destination backup folder : " -NoNewline
                    New-Item -Path $BackupDestination -ItemType Directory > $null
                    If (Test-Path -Path $BackupDestination) { 
                        Write-Host -Object "Ok" -ForegroundColor Green
                    } else {
                        Write-Host -Object 'An error has occurred. Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
                        Exit
                    }
                }
                "no" { 
                    Write-Host -Object 'Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
                    Exit
                }
                Default { Write-Host -Object "Please, answers correctly..." -ForegroundColor Yellow }
            }
        } until (($CreateBackupDestination -match "yes") -or ($CreateBackupDestination -match "no"))
    }
}

function CreateArchiveFilename {
    Try {
        Write-Host "Creating Archive Filename : " -NoNewline
        [String]$Date = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
        [String]$Time = Get-Date -UFormat %H-%M
        [String]$Filename = $Date + "_" + $Time + "_backup" # Name to change
    }
    Catch {
        Write-Host -Object "Error" -ForegroundColor Red 
    }
    Finally {
        Write-Host -Object "Ok" -ForegroundColor Green
    }
}

function Main {
    [String]$Script:FolderToBackup = "C:\Temp\"
    [String]$Script:FilesToBackup = ""
    [String]$Script:BackupDestination = "C:\Temp"
    CorrectRewritingOfVariables
    AreNotTheSame # Not working...
    VerifyBackupDestination
    VerifyFolderToBackup
    CreateArchiveFilename
    
}

# Run the script
Main