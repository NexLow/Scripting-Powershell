<#
.SYNOPSIS
Notifies by email the list of modified files.
.DESCRIPTION
WIP
.NOTES
This script was created by NexLow : https://github.com/NexLow
#>

function GetListOfFiles {
    # Create the date variable
    $Date = (Get-Date).AddDays($NbDays)
    # Create a list of all files
    $Script:ListOfAllFiles = Get-ChildItem -Path $FolderToCheck -Recurse -Include "*.*" | Where-Object {$_.CreationTime -ge $Date} | Sort-Object -Property Name
    # Check if there are any files
    If ($null -eq $ListOfAllFiles) {
        Write-Host -Object "No new file since $Date." -ForegroundColor Red
    } else {
        # Display list of all files
        $NbListOfFiles = $ListOfAllFiles | Measure-Object | Select-Object -ExpandProperty Count
        Write-Host -Object "$NbListOfFiles new files since $Date." -ForegroundColor Green
        Foreach ($Files in $ListOfAllFiles) {
            Write-Host -Object "$Files"
        }
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
    [String]$Script:FolderToCheck = "D:\"
    [Int]$Script:NbDays = "-1"
    GetListOfFiles
    #SendMail
}

# Run the script
Main
