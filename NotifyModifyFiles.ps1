<#
.SYNOPSIS
Notifies by email the list of modified files since X days.
.DESCRIPTION
This script can work automatically with a scheduled task if it is correctly configured. Please test this script before use or automate.
This script does not work with network paths. An absolute local path must be entered for variables $TempFolder and $FolderToCheck.
.NOTES
Author : This script was created by NexLow : https://github.com/NexLow
Creation date : 2020-07-22
Latest review : 2020-07-26
Version : V1.0.0
#>

function SettingUpVariables {
    # This is where you need to modify the variables for the script.

    # The path of a temporary folder. It is used to create de CSV report.
    [String]$Script:TempFolder = "C:\Temp"
    # Number of CSV report to delete in days, exemple : -30 (it delete all files CSV older than 30 days)
    # Set 0 to delete all CSV report after the end of the script.
    [Int]$Script:NbDaysDeleteCSVReport = "-0.5"
    # The folder you want to check.
    [String]$Script:FolderToCheck = "C:\Temp"
    # Lists the files modified since -X days.
    [Int]$Script:NbDays = "-1"
    # Name of your CSV reoprt file.
    [String]$Script:NameCSV = "NewFilesDailyReport"
    

    # Server mail configuration.
    [String]$Script:SmtpUser = "test@test.test" # Your email address like : your@address.com
    [String]$Script:SmtpPassword = "testpasswordtest#" # Your password of your email address !!! Warning !!!
    [String]$Script:SmtpServer = "smtp-mail.outlook.com" # Your email server
    [String]$Script:SmtpPort = "587" # your port server
    #[String]$Script:SmtpPasswordSecure = $($SmtpPassword | ConvertTo-SecureString -AsPlainText -Force) 

    # Mail configuration.
    # The $From must not be an anonymous address. 
    [String]$Script:From = "test@test.test" # Warning
    [String]$Script:To = "test@test.test" # Warning
    [String]$Script:Bcc = "" # Warning

    # Show errors
    $ErrorActionPreference = 'SilentlyContinue'
    <#
    Continue : is the default, and it tells the command to display an error message and continue to run.
    SilentlyContinue : tells the command to display no error message, but to continue running.
    Inquire : tells the command to display a prompt asking the user what to do.
    Stop : tells the command to treat the error as terminating and to stop running.
    #>
}

function StartupMessage {
    # Write a startup message.
    # Get the name of the script.
    $ScriptName = $($myInvocation.ScriptName).Split("\") | Select-Object -Last 1
    Write-Host -Object "=================================================="
    Write-Host -Object "Startup : $ScriptName" 
    Write-Host -Object "=================================================="    
}

function VerifyTempFolder {
    # Checking if $TempFolder is valid and correct rewriting.
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

    # Test if the path is available. 
    If (Test-Path -Path $TempFolder) { 
        Write-Host -Object "The temporary folder `"$TempFolder`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "An error has occurred. Please, enter a valid absolute path for the variable `"`$TempFolder = $TempFolder`" and try again." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function VerifyNbDaysDeleteCSVReport {
    # Check if $NbDaysDeleteCSVReport is valid.
    Write-Host -Object 'Checking if $NbDaysDeleteCSVReport is valid : ' -NoNewline
    If ($null -eq $NbDaysDeleteCSVReport) {
        Write-Host -Object 'Error ! The variable $NbDaysDeleteCSVReport is empty or null. Please, enter a valid number less than "1" exemple "0" or "-1" and try agin.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($NbDaysDeleteCSVReport -ige 1) {
        Write-Host -Object 'Error ! The variable $NbDaysDeleteCSVReport has not a valid number. Please, enter a valid number less than "1" exemple "0" or "-1" and try agin.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        Write-Host -Object "The number `"$NbDaysDeleteCSVReport`" is valid." -ForegroundColor Green
    }
}

function VerifyFolderToCheck {
    # Checking if $FolderToCheck is valid and correct rewriting.
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

    # Test if the path is available.
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
    # Check if $NbDays is valid.
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
    # Verification if the $FolderToCheck is the same as $TempFolder.
    Write-Host -Object 'Checking if $FolderToCheck and $TempFolder are not the same : ' -NoNewline
    If ($FolderToCheck -eq $TempFolder) {
        Write-Host -Object 'Warning ! The folder $FolderToCheck is the same as $TempFolder.' -ForegroundColor Yellow
        do {
            $ContinueAsTheSame = Read-Host -Prompt 'Do you want to continue without changing variables (yes,no) ? '
            switch ($ContinueAsTheSame.ToLower()) {
                "yes" { 
                    Continue
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
    Write-Host -Object "Getting the list of new files : " -NoNewline

    # Create the date variable.
    $Script:Date = (Get-Date).AddDays($NbDays)
    
    # Create a list of all files.
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Script:Date} | Sort-Object -Property Name
    
    # Check if there are any files.
    If ($null -eq $Script:ListOfAllFiles) {
        # No new file, so exit the script.
        Write-Host -Object "No new file since $Script:Date." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        # Display the number of new files in the command prompt.
        $Script:NbListOfFiles = $Script:ListOfAllFiles | Measure-Object | Select-Object -ExpandProperty Count
        Write-Host -Object "$Script:NbListOfFiles new files since $Script:Date." -ForegroundColor Green
        
        # Display list of all files in the command prompt.
        #Foreach ($Script:Files in $Script:ListOfAllFiles) {
        #    Write-Host -Object "$Script:Files"
        #}
    }
}

function CreateCSV {
    # Set variables
    [String]$Script:DateFormat = Get-Date -UFormat %Y-%m-%d # Can be change by : %F
    [String]$Script:TimeFormat = Get-Date -UFormat %H-%M
    [String]$Script:FilenameCSV = $Script:DateFormat + "_" + $Script:TimeFormat + "_" + $Script:NameCSV + ".csv"
    [String]$Script:FullPathFileCSV = $Script:TempFolder + $Script:FilenameCSV

    # Create the CSV report.
    Write-Host -Object "Create the CSV report file : " -NoNewline

    # Test if the file alreday existe.
    If (Test-Path -Path $FullPathFileCSV) {
        Write-Host -Object "The CSV report file `"$FullPathFileCSV`" already exists. Please, try again later." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Date} | Select-Object -Property Name,Directory,FullName,CreationTime | Sort-Object -Property Name | Export-Csv -Encoding utf8 -Delimiter ";" -Path $Script:FullPathFileCSV       
        Write-Host -Object "The CSV report was created : $FullPathFileCSV" -ForegroundColor Green
    }
}

function SendEmail {
    Write-Host -Object "Sending email : " -NoNewline

    $Subject = "[Report] You have $NbListOfFiles new files since $Date"
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

    # Check if the message has been sent successfully.
    if ($?) {
        Write-Host -Object "Email sent." -ForegroundColor Green
    } else {
        Write-Host -Object "Email error ! Please verify the configuration of the email user, password and server. You can retry after that." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function DeleteCSV {
    # Delete old CSV report.
    $DateToDelete = $((Get-Date).AddDays($NbDaysDeleteCSVReport))
    Write-Host -Object "Delete old CSV report files since $DateToDelete : " -NoNewline
    $NumberOfOldCSVFile = Get-ChildItem -Path $TempFolder -Filter "*$NameCSV.csv" -File  | Where-Object { $_.LastWriteTime -lt $DateToDelete } | Measure-Object | Select-Object -ExpandProperty Count
    Get-ChildItem -Path $TempFolder -Filter "*$NameCSV.csv" -File  | Where-Object { $_.LastWriteTime -lt $DateToDelete } | Remove-Item

    # Check if the delete has been execute successfully.
    if ($?) {
        Write-Host -Object "$NumberOfOldCSVFile old files has been deleted." -ForegroundColor Green
    } else {
        Write-Host -Object 'Email error ! Please verify the configuration of $NbDaysDeleteCSVReport variable. You can retry after that.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
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
    VerifyTempFolder
    VerifyNbDaysDeleteCSVReport
    VerifyFolderToCheck
    VerifyNbDays
    AreNotTheSame

    # Creating the list.
    GetListOfFiles

    # Creating the report in CSV.
    CreateCSV

    # Send the email.
    SendEmail

    # Delete temp CSV files.
    DeleteCSV

    # End message.
    EndMessage
}

# Run the script.
Main