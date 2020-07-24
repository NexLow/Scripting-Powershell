<#
.SYNOPSIS
Notifies by email the list of modified files since X days.
.DESCRIPTION
WIP 
A mettre sur le script où sont les fichiers à check
.NOTES
This script was created by NexLow : https://github.com/NexLow
#>

function SettingUpVariables {
    # This is where you need to modify the variables for the script.

    # The folder you want to check.
    [String]$Script:FolderToCheck = "C:\Temp"
    # Lists the files modified since X days
    [Int]$Script:NbDays = "-1"
    # The path of a temporary folder. It is used to create de CSV report.
    [String]$Script:TempFolder = "C:\Temp"

    # Server mail configuration
    [String]$Script:SmtpUser = "" # Your email address like : your@address.com
    [String]$Script:SmtpPassword = "" # Your password of your email address !!! Warning !!!
    [String]$Script:SmtpServer = "smtp-mail.outlook.com" # Your email server
    [String]$Script:SmtpPort = "587" # your port server
    #$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($SmtpPassword | ConvertTo-SecureString -AsPlainText -Force) 

    # Mail configuration
    # The $From must not be an anonymous address. 
    [String]$Script:From = "" # Warning
    [String]$Script:To = "" # Warning
    [String]$Script:Bcc = "" # Warning
}

function StartupMessage {
    # Write a startup message
    # Get the name of the script
    $ScriptName = $($myInvocation.ScriptName).Split("\") | Select-Object -Last 1

    Write-Host -Object "=================================================="
    Write-Host -Object "Startup : $ScriptName" 
    Write-Host -Object "=================================================="    
}

function VerifyTempFolder {
    # Checking if $TempFolder is valid and correct rewriting
    Write-Host -Object 'Checking if $TempFolder is valid and correct rewriting : ' -NoNewline
    If ($null -eq $TempFolder) {
        Write-Host -Object 'Error ! This script needs a temp folder. Please, enter a valid absolute path for the variable "$TempFolder" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif (($TempFolder -eq "") -or ($TempFolder -match " ") -or ($TempFolder -match '^\\') -or ($TempFolder -match '^.\\')) {
        Write-Host -Object 'Error ! Please, enter a valid absolute path for the variable "$TempFolder" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($TempFolder -notmatch '\\$') {
        [Int]$LengthTempFolder = $TempFolder.Length
        [String]$Script:TempFolder = $TempFolder.Insert($LengthTempFolder,"\")
    }

    # Test if the path is available 
    If (Test-Path -Path $TempFolder) { 
        Write-Host -Object "The temporary folder `"$TempFolder`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "An error has occurred. Please, enter a valid absolute path for the variable `"`$TempFolder = $TempFolder`" and try again." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function VerifyFolderToCheck {
    # Checking if $FolderToCheck is valid and correct rewriting
    Write-Host -Object 'Checking if $FolderToCheck is valid and correct rewriting : ' -NoNewline
    If ($null -eq $FolderToCheck) {
        Write-Host -Object 'Error ! This script needs a temp folder. Please, enter a valid absolute path for the variable "$FolderToCheck" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif (($FolderToCheck -eq "") -or ($FolderToCheck -match " ") -or ($FolderToCheck -match '^\\') -or ($FolderToCheck -match '^.\\')) {
        Write-Host -Object 'Error ! Please, enter a valid absolute path for the variable "$FolderToCheck" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($FolderToCheck -notmatch '\\$') {
        [Int]$LengthFolderToCheck = $FolderToCheck.Length
        [String]$Script:FolderToCheck = $FolderToCheck.Insert($LengthFolderToCheck,"\")
    }

    # Test if the path is available 
    If (Test-Path -Path $FolderToCheck) { 
        Write-Host -Object "The folder `"$FolderToCheck`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "An error has occurred. Please, enter a valid absolute path for the variable `"`$FolderToCheck = $FolderToCheck`" and try again." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function VerifyNbDays {
    # Check if $NbDays is valid
    Write-Host -Object 'Checking if $NbDays is valid : ' -NoNewline
    If ($null -eq $NbDays) {
        Write-Host -Object 'Error ! The variable $NbDays is empty or null. Please, enter a valid number less than "0" exemple "-1" and try agin.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($NbDays -ige 0) {
        Write-Host -Object 'Error ! The variable $NbDays has not a valid number. Please, enter a valid number less than "0" exemple "-1" and try agin.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        Write-Host -Object "The number `"$NbDays`" is valid." -ForegroundColor Green
    }
}

function AreNotTheSame {
    # Verification if the $FolderToCheck is the same as $TempFolder
    Write-Host -Object 'Checking if $FolderToCheck and $TempFolder are not the same : ' -NoNewline
    If ($FolderToCheck -eq $TempFolder) {
        Write-Host -Object 'Warning ! The folder $FolderToCheck is the same as $TempFolder.' -ForegroundColor Yellow
        do {
            $ContinueAsTheSame = Read-Host -Prompt 'Do you want to continue without changing variables (yes,no) ? '
            switch ($ContinueAsTheSame.ToLower()) {
                "yes" { 
                    Write-Host -Object "No problem, we continue..." -ForegroundColor Green
                }
                "no" { 
                    Write-Host -Object 'So please, enter a different valid absolute path for variables "$FolderToCheck" and "$TempFolder". You can retry after that.' -ForegroundColor Red
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

function GetListOfFiles {
    # Create the date variable
    $Script:Date = (Get-Date).AddDays($NbDays)
    # Create a list of all files
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Script:Date} | Sort-Object -Property Name
    # Check if there are any files
    If ($null -eq $Script:ListOfAllFiles) {
        # no new file, so exit the script
        Write-Host -Object "No new file since $Script:Date." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        # Display list of all files
        $Script:NbListOfFiles = $Script:ListOfAllFiles | Measure-Object | Select-Object -ExpandProperty Count
        Write-Host -Object "$Script:NbListOfFiles new files since $Script:Date." -ForegroundColor Green
        Foreach ($Script:Files in $Script:ListOfAllFiles) {
            Write-Host -Object "$Script:Files"
        }
    }
}

function CreateCSV {
    [String]$Script:DateFormat = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
    [String]$Script:TimeFormat = Get-Date -UFormat %H-%M
    [String]$Script:FilenameCSV = $Script:DateFormat + "_" + $Script:TimeFormat + "_NewFilesDailyReport.csv"
    [String]$Script:FullPathFileCSV = $Script:TempFolder + $Script:FilenameCSV
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Date} | Select-Object -Property Name,Directory,FullName,CreationTime | Sort-Object -Property Name | Export-Csv -Encoding utf8 -Delimiter ";" -Path $Script:FullPathFileCSV
}

function SendMail {
    $Subject = "[Daily report] You have $NbListOfFiles new files since $Date"
    $Body = "Hello, you will find a file in CSV format attached to this mail, which contains the list of $NbListOfFiles new files since $Date"
    $Attachments = $FullPathFileCSV

    $Mail = New-Object System.Net.Mail.MailMessage
    $Mail.From = $From
    $Mail.To.Add($To)
    $Mail.Subject = $Subject
    $Mail.Body = $Body
    $Mail.Attachments.Add($Attachments)
    $Mail.IsBodyHtml = $true
    
    $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort);
    $Smtp.UseDefaultCredentials = $false;
    $Smtp.EnableSSL = $true
    $Smtp.Credentials = New-Object System.Net.NetworkCredential($SmtpUser, $SmtpPassword);
    $Smtp.Send($Mail);
}

function Main {
    # Startup message
    StartupMessage

    # Setting up variables
    SettingUpVariables 

    # Verification of variables
    VerifyTempFolder
    VerifyFolderToCheck
    VerifyNbDays
    AreNotTheSame

    # Creating the list
    GetListOfFiles

    # Verification of new file
    #VerifyIfNewFiles

    # Creating the report in CSV
    #CreateCSV #Verify after creating the csv

    # Send the email
    #SendMail # Check value

    # Delete temp CSV files
    #DeleteCSV
}

# Run the script
Main