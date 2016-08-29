<#
Must be run as Admin to start services
Perform check if nexposeconsole service is running
If service is running then log "Service is up" and the date and time
If the service is not running Send an email alerting the service is down attempt to start the service every 10 second and log each attempt
When service is restored send email stating service has been restored
Continue to check service status


###################
To utilize this script you will need to edit the following:

>UserName - Username for the Nexpose service account
>Password - Password for the Nexpose service account
>Send-MailMessage -from - Make this the email address for the service account you use for nexpose
>Send-MailMessage -to - Make this an email address that you monitor
>Send-MailMessage -SmtpServer - This will be the email server you use to send the alerts
#>

$UserName = "UserName"
$Passwd = ConvertTo-SecureString -String "P@ssW0rd" -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential($UserName,$Passwd)

$mailCount = 0

while ($true)
    {
        $Ddate = Get-Date
        if ((Get-Service nexposeconsole).Status -ne "Running")
            {
            Start-Service nexposeconsole
            Add-Content $env:USERPROFILE\Documents\NexposeConsoleLog.txt "$Ddate - Attempting to start service"
            if ($mailCount -eq 0)
                {
                Send-MailMessage -to "MyAlertAccount@company.net" -from "Nexpose.services@company.net" -subject "$env:COMPUTERNAME - $Ddate Nexpose Security Console is down" -Body "$env:COMPUTERNAME`nNexpose Security Console has stopped.`n`nThank you" -credential $Creds -SmtpServer "ExchangeServA.Company.net"
                $mailCount += 1
                Start-Sleep -Seconds 10
                }
            else
                {
                Start-Sleep -Seconds 10
                }
            }
        else
            {
            Add-Content $env:USERPROFILE\Documents\NexposeConsoleLog.txt "$Ddate - Service is up"
            if ($mailCount -eq 1)
                {
                Send-MailMessage -to "MyAlertAccount@company.net" -from "Nexpose.services@company.net" -subject "$env:COMPUTERNAME - $Ddate Nexpose Security Console is restored" -Body "$env:COMPUTERNAME`nNexpose Security Console is restored." -credential $Creds -SmtpServer "ExchangeServA.Company.net"
                $mailCount = 0
                Start-Sleep -Seconds 60
                }
            else
                {
                Start-Sleep -Seconds 60
                }
            }
    }