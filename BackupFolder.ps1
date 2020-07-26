<#
.SYNOPSIS
Backup the folder you want with the date in zip format.
.DESCRIPTION
This script can work automatically with a scheduled task if it is correctly configured. Please test this script before use or automate.
This script does not work with network paths. An absolute local path must be entered for variables $FolderToBackup and $BackupDestination.
.NOTES
Author : This script was created by NexLow : https://github.com/NexLow
Creation date : 2020-07-22
Latest review : 2020-07-26
Version : V1.0.0
#>

function StartupMessage {
    # Write a startup message.
    # Get the name of the script.
    $ScriptName = $($myInvocation.ScriptName).Split("\") | Select-Object -Last 1
    Write-Host -Object "=================================================="
    Write-Host -Object "Startup : $ScriptName" 
    Write-Host -Object "=================================================="    
}

function SettingUpVariables {
    # This is where you need to modify the variables for the script.
    
    # The folder you want to backup.
    [String]$Script:FolderToBackup = "C:\Temp\FolderToBackup"
    # The folder destination of the backup.
    [String]$Script:BackupDestination = "C:\Temp\BackupDestination\"
    # Set the name of the backup.
    [String]$Script:NameOfBackupFile = "backup"
    
    # Show errors
    $ErrorActionPreference = 'SilentlyContinue'
    <#
    Continue : is the default, and it tells the command to display an error message and continue to run.
    SilentlyContinue : tells the command to display no error message, but to continue running.
    Inquire : tells the command to display a prompt asking the user what to do.
    Stop : tells the command to treat the error as terminating and to stop running.
    #>
}

function VerifyFolderToBackup {
    # Checking if $FolderToBackup is valid and correct rewriting.
    Write-Host -Object 'Checking if $FolderToBackup is valid and correct rewriting : ' -NoNewline
    If ($null -eq $FolderToBackup) {
        Write-Host -Object 'Error ! This script needs a temp folder. Please, enter a valid absolute path for the variable "$FolderToBackup" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif (($FolderToBackup -eq "") -or ($FolderToBackup -match " ") -or ($FolderToBackup -match '^\\') -or ($FolderToBackup -match '^.\\')) {
        Write-Host -Object 'Error ! Please, enter a valid absolute path for the variable "$FolderToBackup" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($FolderToBackup -notmatch '\\$') {
        [Int]$LengthFolderToBackup = $FolderToBackup.Length
        [String]$Script:FolderToBackup = $FolderToBackup.Insert($LengthFolderToBackup,"\")
    }

    # Test if the path is available. 
    If (Test-Path -Path $FolderToBackup) { 
        Write-Host -Object "The temporary folder `"$FolderToBackup`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "An error has occurred. Please, enter a valid absolute path for the variable `"`$FolderToBackup = $FolderToBackup`" and try again." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function VerifyBackupDestination {
    # Checking if $BackupDestination is valid and correct rewriting.
    Write-Host -Object 'Checking if $BackupDestination is valid and correct rewriting : ' -NoNewline
    If ($null -eq $BackupDestination) {
        Write-Host -Object 'Error ! This script needs a temp folder. Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif (($BackupDestination -eq "") -or ($BackupDestination -match " ") -or ($BackupDestination -match '^\\') -or ($BackupDestination -match '^.\\')) {
        Write-Host -Object 'Error ! Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($BackupDestination -notmatch '\\$') {
        [Int]$LengthBackupDestination = $BackupDestination.Length
        [String]$Script:BackupDestination = $BackupDestination.Insert($LengthBackupDestination,"\")
    }
    
    # Test if the path is available. 
    If (Test-Path -Path $BackupDestination) { 
        Write-Host -Object "The destination folder `"$BackupDestination`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "The folder `"$BackupDestination`" does not exist." -ForegroundColor Red
        do {
            $CreateBackupDestination = Read-Host -Prompt "Do you want to create `"$BackupDestination`" (yes,no) ? "
            switch ($CreateBackupDestination.ToLower()) {
                "yes" { 
                    Write-Host -Object 'Creation and verification if $BackupDestination is valid and correct rewriting : ' -NoNewline
                    New-Item -Path $BackupDestination -ItemType Directory > $null
                    If (Test-Path -Path $BackupDestination) { 
                        Write-Host -Object "The destination folder `"$BackupDestination`" exist and is valid." -ForegroundColor Green
                    } else {
                        Write-Host -Object 'An error has occurred. Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
                        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
                        Start-Sleep -Seconds 10
                        Exit
                    }
                }
                "no" { 
                    Write-Host -Object 'Please, enter a valid absolute path for the variable "$BackupDestination" and try again.' -ForegroundColor Red
                    Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
                    Start-Sleep -Seconds 10
                    Exit                
                }
                Default { Write-Host -Object "Please, answers correctly..." -ForegroundColor Yellow }
            }
        } until (($CreateBackupDestination -match "yes") -or ($CreateBackupDestination -match "no"))
    }
}

function AreNotTheSame {
    # Verification if the $FolderToBackup is the same as $BackupDestination
    Write-Host -Object 'Checking if $FolderToBackup and $BackupDestination are not the same : ' -NoNewline
    If ($FolderToBackup -eq $BackupDestination) {
        Write-Host -Object 'Warning ! The folder $FolderToBackup is the same as $BackupDestination.' -ForegroundColor Yellow
        do {
            $ContinueAsTheSame = Read-Host -Prompt 'Do you want to continue without changing variables (yes,no) ? '
            switch ($ContinueAsTheSame.ToLower()) {
                "yes" { 
                    Continue
                }
                "no" { 
                    Write-Host -Object 'So please, enter a different valid absolute path for variables "$FolderToBackup" and "$BackupDestination". You can retry after that.' -ForegroundColor Red
                    Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
                    Start-Sleep -Seconds 10
                    Exit
                }
                Default { Write-Host -Object "Please, answers correctly..." -ForegroundColor Yellow }
            }
        } until (($ContinueAsTheSame -match "yes") -or ($ContinueAsTheSame -match "no"))
    } else {
        Write-Host -Object "They are not the same. It is ok." -ForegroundColor Green
    }
}

function CreateArchiveFilename {
    # Create the name of the archive file that will be used for the backup file.
    Write-Host "Creating Archive Filename : " -NoNewline
    Try {
        [String]$Date = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
        [String]$Time = Get-Date -UFormat %H-%M
        [String]$Filename = $Date + "_" + $Time + "_" + $NameOfBackupFile + ".zip"
        [String]$Script:FullFilename = $BackupDestination + $Filename
    }
    Catch {
        Write-Host -Object "An error has occurred. Please, try again." -ForegroundColor Red 
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
    Finally {
        Write-Host -Object "Ready." -ForegroundColor Green
    }
}

function BackupFolder {
    # Backup $FolderToBackup.
    Write-Host -Object "Creating the backup : " -NoNewline

    # Check if the backup does not already exist.
    If (Test-Path -Path $FullFilename) {
        Write-Host -Object "The backup `"$FullFilename`" already exist." -ForegroundColor Red 
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } Else {
        Compress-Archive -Path $FolderToBackup -DestinationPath $FullFilename > $null
        If (Test-Path -Path $FullFilename) {
            Write-Host -Object "The backup `"$FullFilename`" was created" -ForegroundColor Green 
        } Else {
            Write-Host -Object "An error has occurred. The backup `"$FullFilename`" does not exist" -ForegroundColor Red
            Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
            Start-Sleep -Seconds 10
            Break
        }
    }
}

function EndMessage {
    # Write an end message.
    # Get the name of the script.
    $ScriptName = $($myInvocation.ScriptName).Split("\") | Select-Object -Last 1
    Write-Host -Object "=================================================="
    Write-Host -Object "End of the script : $ScriptName" 
    Write-Host -Object "=================================================="
}

function Main {
    # Startup message.
    StartupMessage
    
    # Setting up variables.
    SettingUpVariables 

    # Verification of variables.
    VerifyFolderToBackup
    VerifyBackupDestination
    AreNotTheSame
    
    # Create the archive filename.
    CreateArchiveFilename

    # Backuping.
    BackupFolder

    # End message.
    EndMessage
}

# Run the script
Main