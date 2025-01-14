#!/bin/bash

# Function to display messages with colors
display_message() {
    local message="$1"
    local color="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    case $color in
        red) echo -e "\033[91m[$timestamp] ${message}\033[0m" ;;
        green) echo -e "\033[92m[$timestamp] ${message}\033[0m" ;;
        yellow) echo -e "\033[93m[$timestamp] ${message}\033[0m" ;;
        blue) echo -e "\033[94m[$timestamp] ${message}\033[0m" ;;
        *) echo "[$timestamp] $message" ;;
    esac
}

# Function to display help text
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -SmtpServer <server>      SMTP server address (default: fallbackprefix.mail.protection.outlook.com)"
    echo "  -To <recipient>           Recipient email address (default: recipient@fallbackprefix.onmicrosoft.com)"
    echo "  -From <sender>            Sender email address (default: sender@fallbackprefix.onmicrosoft.com)"
    echo "  -Subject <subject>        Email subject (default: Mail test)"
    echo "  -Body <body>              Email body (HTML format)"
    echo "  -FirstName <firstname>    Sender's first name (default: Firstname)"
    echo "  -LastName <lastname>      Sender's last name (default: Lastname)"
    echo "  -Attachments <files>      Comma-separated list of attachment files"
    echo "  -Cc <cc>                  CC email addresses"
    echo "  -Bcc <bcc>                BCC email addresses"
    echo "  -Priority <priority>      Email priority (Low, Normal, High)"
    echo "  -h, --help                Display this help text"
    echo
    echo "Example:"
    echo "  $0 -SmtpServer smtp.example.com -To recipient@example.com -From sender@example.com -Subject 'Test Email' -Body '<html><body><h1>Hello</h1></body></html>' -FirstName 'SenderFirstName' -LastName 'SenderLastName' -Attachments 'file1.txt,file2.pdf' -Cc 'cc@example.com' -Bcc 'bcc@example.com' -Priority 'High'"
}

# Default values
smtp_server="fallbackprefix.mail.protection.outlook.com"
mail_address="spoofer@fallbackprefix.onmicrosoft.com"
firstname="SpoofedFirstname"
lastname="SpoofedLastname"
recipient="helpdesk@fallbackprefix.onmicrosoft.com"
subject="Spoofing test"
email_body='<!DOCTYPE html><html><body><p>Hallo Herr Mustermann</p><p>Message goes Here</p><p>Here is a <a href="https://www.google.de">https://www.google.de</a></p><p>Grüße</p><p>Tester</p></body></html>'

# Check if pwsh is available
if ! command -v pwsh &> /dev/null; then
    display_message "Error: pwsh (PowerShell) is not installed or not available in PATH." "red"
    exit 1
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -SmtpServer)
            smtp_server="$2"
            shift 2
            ;;
        -To)
            recipient="$2"
            shift 2
            ;;
        -From)
            mail_address="$2"
            shift 2
            ;;
        -Subject)
            subject="$2"
            shift 2
            ;;
        -Body)
            email_body="$2"
            shift 2
            ;;
        -FirstName)
            firstname="$2"
            shift 2
            ;;
        -LastName)
            lastname="$2"
            shift 2
            ;;
        -Attachments)
            attachments="$2"
            shift 2
            ;;
        -Cc)
            cc="$2"
            shift 2
            ;;
        -Bcc)
            bcc="$2"
            shift 2
            ;;
        -Priority)
            priority="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        *)
            display_message "Unknown option: $1" "red"
            display_help
            exit 1
            ;;
    esac
done

# Execute the PowerShell command
pwsh -Command "\$smtpServer = '$smtp_server'; \$mailAddress = '$mail_address'; \$firstname = '$firstname'; \$lastname = '$lastname'; \$recipient = '$recipient'; \$subject = '$subject'; \$body = '$email_body'; \$from = New-Object System.Net.Mail.MailAddress(\$mailAddress, \"\$firstname \$lastname\"); try { Send-MailMessage -SmtpServer \$smtpServer -To \$recipient -From \$from -Subject \$subject -Body \$body -BodyAsHtml -Encoding ([System.Text.Encoding]::UTF8); Write-Output 'Email sent to \$recipient with subject \$subject from \$mailAddress' } catch { Write-Output 'Error sending email to \$recipient: \$($_.Exception.Message)'; exit 1 }"
result=$?

# Check the result of the PowerShell command
if [ $result -eq 0 ]; then
    display_message "Email sent successfully to $recipient." "green"
else
    display_message "Failed to send email." "red"
fi

# Example command to run the script:
# ./sendmail.sh -SmtpServer smtp.example.com -To recipient@example.com -From sender@example.com -Subject 'Test Email' -Body '<html><body><h1>Hello</h1></body></html>' -FirstName 'SenderFirstName' -LastName 'SenderLastName' -Attachments 'file1.txt,file2.pdf' -Cc 'cc@example.com' -Bcc 'bcc@example.com' -Priority 'High'
