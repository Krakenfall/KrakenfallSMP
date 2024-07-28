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
    [string]$dnsZoneName,
    [string]$fqdn,
    [string]$azDnsRgName
)
$subdomain = $fqdn.Replace("$dnsZoneName",'')
$dnsRecordSetName = ($txtName,$subdomain -join '.')
# Remove the _acme-challenge TXT record after the domain has been verified and certificate has been generated
Remove-AzDnsRecordSet -Name $dnsRecordSetName -RecordType TXT -ZoneName "$dnsZoneName" -ResourceGroupName "$azDnsRgName"
