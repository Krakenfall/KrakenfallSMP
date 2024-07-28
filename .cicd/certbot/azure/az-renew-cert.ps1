#
# az-create-cert.ps1
#
# Description: This script installs certbot, runs the renewal/creation command, converts the certificate to .pfx, then uploads to a key vault.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen
param(
    [string]$email,
    [string]$domain,
    [string]$keyVaultName,
    [string]$azDnsRgName,
    [string]$txtName,
    [string]$PKPWD
)
# Change these variables based on your domain info
$certFileName       = $domain.Replace('.','-')
$authHookPath       = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\.cicd\certbot\azure\az-auth.ps1 -txtName $txtName -domain $domain -azDnsRgName $azDnsRgName"
$cleanupHookPath    = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\.cicd\certbot\azure\cleanup.ps1 -txtName $txtName -domain $domain -azDnsRgName $azDnsRgName"

# install openssl
choco install openssl --no-progress

# Install certbot
Invoke-WebRequest -Uri https://dl.eff.org/certbot-beta-installer-win32.exe -OutFile "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\certbot-beta-installer-win32.exe"

cd $($env:SYSTEM_DEFAULTWORKINGDIRECTORY)

# /D not working
Start-Process -Wait -FilePath ".\certbot-beta-installer-win32.exe" -ArgumentList "/S" -PassThru

cd "C:\Program Files (x86)\Certbot\bin"

# Request a new certificate
.\certbot.exe certonly --manual --preferred-challenges=dns --manual-auth-hook $authHookPath -d $domain --email $email --manual-cleanup-hook $cleanupHookPath --agree-tos -n

cd "C:\Certbot\live\$domain\"

# Convert certificate to .pfx
openssl pkcs12 -export -out "$certFileName.pfx" -inkey privkey.pem -in fullchain.pem -passout pass:$(PKPWD)

# Import certificate to KeyVault
# __PKPWD__ is a secret pipeline (group) variable whose value is mapped to a KV secret
$password = ConvertTo-SecureString -String "$PKPWD" -AsPlainText -Force
Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certFileName -FilePath "$certFileName.pfx" -Password $password
