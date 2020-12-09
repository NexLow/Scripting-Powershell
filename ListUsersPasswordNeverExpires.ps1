<#
.SYNOPSIS
This script allows you to report on users who have the "PasswordNeverExpires" setting enabled.
.DESCRIPTION
This script can work automatically with a scheduled task if it is correctly configured. Please test this script before use or automate.
This script does not work with network paths. An absolute local path must be entered for variables $LogPathPasswordNeverExipres.
.NOTES
Author : This script was created by NexLow : https://github.com/NexLow
Creation date : 2020-08-21
Latest review : 2020-09-21
Version : V1.0.0
#>

function SettingUpVariables {
    # Set the date variable (do not modify).
    $Script:Date = Get-Date -Format yyyy-MM-dd

    # The path and the filename of the log for PasswordNeverExipres.
    [String]$Script:LogPathPasswordNeverExipres = "C:\Logs\PasswordNeverExipres\"
    [String]$Script:LogFilenamePasswordNeverExipres = $Date + "_PasswordNeverExipres.csv"
    [String]$Script:LogPasswordNeverExipres = $LogPathPasswordNeverExipres + $LogFilenamePasswordNeverExipres
    
    # Server mail configuration.
    [String]$Script:SmtpUser = "" # Your email address like : your@address.com
    [String]$Script:SmtpPassword = "" # Your password of your email address !!! Warning !!!
    [String]$Script:SmtpServer = "" # Your email server
    [String]$Script:SmtpPort = "25" # your port server
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

function VerifyLogPasswordNeverExipres {
    # Checking if $LogPathPasswordNeverExipres is valid and correct rewriting.
    Write-Host -Object 'Checking if $LogPathPasswordNeverExipres is valid and correct rewriting : ' -NoNewline
    If ($null -eq $LogPathPasswordNeverExipres) {
        Write-Host -Object 'Error ! This script needs a log folder. Please, enter a valid absolute path for the variable "$LogPathPasswordNeverExipres" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif (($LogPathPasswordNeverExipres -eq "") -or ($LogPathPasswordNeverExipres -match " ") -or ($LogPathPasswordNeverExipres -match '^\\') -or ($LogPathPasswordNeverExipres -match '^.\\')) {
        Write-Host -Object 'Error ! Please, enter a valid absolute path for the variable "$LogPathPasswordNeverExipres" and try again.' -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } elseif ($LogPathPasswordNeverExipres -notmatch '\\$') {
        [Int]$LengthLogPathPasswordNeverExipres = $LogPathPasswordNeverExipres.Length
        [String]$Script:LogPathPasswordNeverExipres = $LogPathPasswordNeverExipres.Insert($LengthLogPathPasswordNeverExipres,"\")
    }

    # Test if the path is available. 
    If (Test-Path -Path $LogPathPasswordNeverExipres) { 
        Write-Host -Object "The folder `"$LogPathPasswordNeverExipres`" exist and is valid." -ForegroundColor Green
    } else {
        Write-Host -Object "An error has occurred. Please, enter a valid absolute path for the variable `"`$LogPathPasswordNeverExipres = $LogPathPasswordNeverExipres`" and try again." -ForegroundColor Red
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    }
}

function GetListUsersPasswordNeverExpires {
    Write-Host "Get list of users who have the `"PasswordNeverExpires`" setting enabled : " -NoNewline
    $Script:ListUsersPasswordNeverExpires = Get-ADUser -Filter * -Properties Name,GivenName,Surname,SamAccountName,PasswordNeverExpires | 
        Where-Object { $_.passwordNeverExpires -eq "true" } | 
        Where-Object {$_.enabled -eq "true"}
    $Script:NumberUsersPasswordNeverExpires = $ListUsersPasswordNeverExpires | Measure-Object | Select-Object -ExpandProperty Count
    If ($NumberUsersPasswordNeverExpires -eq 0) {
        Write-Host -Object "0 user found." -ForegroundColor Yellow
        Write-Host -Object "Exit the script in 10 seconds..." -NoNewline
        Start-Sleep -Seconds 10
        Exit
    } else {
        Write-Host -Object "$NumberUsersPasswordNeverExpires user(s) found." -ForegroundColor Green
    }
}

function GenerateCSVReport {
    $ListUsersPasswordNeverExpires = $ListUsersPasswordNeverExpires | Select-Object -Property Name,GivenName,Surname,SamAccountName,PasswordNeverExpires | Export-CSV -Path $LogPasswordNeverExipres -Encoding UTF8
}

function SendMailReport {
    Write-Host -Object "Sending email : " -NoNewline

    $Subject = "[Report Active Directory] You have $NumberUsersPasswordNeverExpires user(s) who have the `"PasswordNeverExpires`" setting enabled."
    $Body = "Hello, you will find a file in CSV format attached to this mail, which contains the list of $NumberUsersPasswordNeverExpires user(s) who have the `"PasswordNeverExpires`" setting enabled. Have a good day."
    $Attachments = $LogPasswordNeverExipres

    $Mail = New-Object System.Net.Mail.MailMessage
    $Mail.From = $From
    $Mail.To.Add($To)
    $Mail.Subject = $Subject
    $Mail.Body = $Body
    $Mail.Attachments.Add($Attachments)
    $Mail.IsBodyHtml = $true
    
    $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort);
    $Smtp.UseDefaultCredentials = $false;
    $Smtp.EnableSSL = $false
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

function Main {
    StartupMessage
    SettingUpVariables
    VerifyLogPasswordNeverExipres
    GetListUsersPasswordNeverExpires
    GenerateCSVReport
    SendMailReport
}

Main