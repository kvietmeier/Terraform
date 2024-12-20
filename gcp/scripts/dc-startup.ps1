
$ErrorActionPreference = "Stop"

#
# Only run the script if the VM is not a domain controller already.
#
if ((Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 2) {
    exit
}

#
# Read configuration from metadata.
#
Import-Module "${Env:ProgramFiles}\Google\Compute Engine\sysprep\gce_base.psm1"

$ActiveDirectoryDnsDomain     = Get-MetaData -Property "attributes/ActiveDirectoryDnsDomain" -instance_only
$ActiveDirectoryNetbiosDomain = Get-MetaData -Property "attributes/ActiveDirectoryNetbiosDomain" -instance_only
$ActiveDirectoryFirstDc       = Get-MetaData -Property "attributes/ActiveDirectoryFirstDc" -instance_only
$ProjectId                    = Get-MetaData -Property "project-id" -project_only
$Hostname                     = Get-MetaData -Property "hostname" -instance_only
$AccessToken                  = (Get-MetaData -Property "service-accounts/default/token" | ConvertFrom-Json).access_token

#
# Read the DSRM password from secret manager.
#
$Secret = (Invoke-RestMethod `
    -Headers @{
        "Metadata-Flavor" = "Google";
        "x-goog-user-project" = $ProjectId;
        "Authorization" = "Bearer $AccessToken"} `
    -Uri "https://secretmanager.googleapis.com/v1/projects/$ProjectId/secrets/ad-password/versions/latest:access")
$DsrmPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Secret.payload.data))
$DsrmPassword = ConvertTo-SecureString -AsPlainText $DsrmPassword -force

#
# Promote.
#
Write-Host "Setting administrator password..."
Set-LocalUser -Name Administrator -Password $DsrmPassword

if ($ActiveDirectoryFirstDc -eq $env:COMPUTERNAME) {
    Write-Host "Creating a new forest $ActiveDirectoryDnsDomain ($ActiveDirectoryNetbiosDomain)..."
    Install-ADDSForest `
        -DomainName $ActiveDirectoryDnsDomain `
        -DomainNetbiosName $ActiveDirectoryNetbiosDomain `
        -SafeModeAdministratorPassword $DsrmPassword `
        -DomainMode Win2008R2 `
        -ForestMode Win2008R2 `
        -InstallDns `
        -CreateDnsDelegation:$False `
        -NoRebootOnCompletion:$True `
        -Confirm:$false
}
else {
    do {
        Write-Host "Waiting for domain to become available..."
        Start-Sleep -s 60
        & ipconfig /flushdns | Out-Null
        & nltest /dsgetdc:$ActiveDirectoryDnsDomain | Out-Null
    } while ($LASTEXITCODE -ne 0)

    Write-Host "Adding DC to $ActiveDirectoryDnsDomain ($ActiveDirectoryNetbiosDomain)..."
    Install-ADDSDomainController `
        -DomainName $ActiveDirectoryDnsDomain `
        -SafeModeAdministratorPassword $DsrmPassword `
        -InstallDns `
        -Credential (New-Object System.Management.Automation.PSCredential ("Administrator@$ActiveDirectoryDnsDomain", $DsrmPassword)) `
        -NoRebootOnCompletion:$true  `
        -Confirm:$false
}

#
# Configure DNS.
#
Write-Host "Configuring DNS settings..."
Get-Netadapter| Disable-NetAdapterBinding -ComponentID ms_tcpip6
Set-DnsClientServerAddress  `
    -InterfaceIndex (Get-NetAdapter -Name Ethernet).InterfaceIndex `
    -ServerAddresses 127.0.0.1

#
# Enable LSA protection.
#
New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "RunAsPPL" `
    -Value 1 `
    -PropertyType DWord

Write-Host "Restarting to apply all settings..."
Restart-Computer

