<#
.SYNOPSIS
Notifies by email the list of modified files.
.DESCRIPTION
WIP
.NOTES
This script was created by NexLow : https://github.com/NexLow
#>

function GetListOfFiles {
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Include @($Extension) -Recurse
    Foreach ($Files in $ListOfAllFiles) {
        Write-Host -Object "$Files"
    }
}

function SendMail {
    # Server configuration
    $SmtpUser = "test@test.test"
    $SmtpPassword = "testpassword"
    $SmtpServer = "smtp-mail.outlook.com"
    $SmtpPort = "587"
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($SmtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
    
    # Mail configuration
    # The $From must not be an anonymous address. 
    $From = "test@test.test"
    $To = "test@test.test"
    $Bcc = ""
    $Subject = "test mail"
    $Body = "test mail body"

    $Mail = New-Object System.Net.Mail.MailMessage
    $Mail.From = $From
    $Mail.To.Add($To)
    $Mail.Subject = $Subject
    $Mail.Body = $Body
    $Mail.IsBodyHtml = $true
    
    $Smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort);
    $Smtp.UseDefaultCredentials = $false;
    $Smtp.EnableSSL = $true
    $Smtp.Credentials = New-Object System.Net.NetworkCredential($SmtpUser, $SmtpPassword);
    $Smtp.Send($Mail);
}

function Main {
    [String]$Script:FolderToCheck = "C:\Temp"
    [String]$Script:Extension = "*.zip", "*.txt"
    GetListOfFiles
    SendMail
}

# Run the script
Main
