<#
.SYNOPSIS
Notifies by email the list of modified files since X days.
.DESCRIPTION
WIP
.NOTES
This script was created by NexLow : https://github.com/NexLow
#>

function GetListOfFiles {
    # Create the date variable
    $Script:Date = (Get-Date).AddDays($NbDays)
    # Create a list of all files
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Script:Date} | Sort-Object -Property Name
    # Check if there are any files
    If ($null -eq $Script:ListOfAllFiles) {
        # no new file, so exit the script
        Write-Host -Object "No new file since $Script:Date." -ForegroundColor Red
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
    [String]$Script:FullPathFileCSV = "C:\Temp\$Script:FilenameCSV"
    $Script:ListOfAllFiles = Get-ChildItem -Path $Script:FolderToCheck -Recurse -File | Where-Object {$_.CreationTime -ge $Date} | Select-Object -Property Name,Directory,FullName,CreationTime | Sort-Object -Property Name | Export-Csv -Encoding utf8 -Delimiter ";" -Path $Script:FullPathFileCSV
}

function SendMail {
    # Server configuration
    $SmtpUser = "" # Warning
    $SmtpPassword = "" # Warning
    $SmtpServer = "smtp-mail.outlook.com"
    $SmtpPort = "587"
    #$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($SmtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
    
    # Mail configuration
    # The $From must not be an anonymous address. 
    $From = "" # Warning
    $To = "" # Warning
    $Bcc = "" # Warning
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
    [String]$Script:FolderToCheck = "C:\Temp"
    [Int]$Script:NbDays = "-1"

    #CheckIfTempFolderExist # Not Created
    GetListOfFiles
    CreateCSV
    SendMail
    #DeleteCSV # Not created
}

# Run the script
Main

