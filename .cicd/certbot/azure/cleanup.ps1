#
# cleanup.ps1
#
# Description: This script removes the TXT record that was added from the auth-hook script after the certificate has been created.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen
param(
    [string]$txtName,
    [string]$domain,
    [string]$azDnsRgName
)
# Remove the _acme-challenge TXT record after the domain has been verified and certificate has been generated
Remove-AzDnsRecordSet -Name "$txtName" -RecordType TXT -ZoneName "$domain" -ResourceGroupName "$azDnsRgName"
