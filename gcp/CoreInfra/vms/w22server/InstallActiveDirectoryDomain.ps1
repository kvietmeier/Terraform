# Install the Active Directory Domain Services (AD DS) role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDSDeployment module
Import-Module ADDSDeployment

# Promote the server to a Domain Controller
Install-ADDSForest -DomainName "ginaz.org" `
    -DomainNetbiosName "ginaz" `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String "Chalc0pyr1te!123" -AsPlainText -Force)

# Reboot the system if necessary
Restart-Computer

# Create a new Organizational Unit (OU)
New-ADOrganizationalUnit -Name "VAST" -Path "DC=ginaz,DC=org"

# Redirect new computer accounts to the new OU
redircmp "OU=VAST,DC=ginaz,DC=org"

# Move existing computer accounts if needed
Get-ADComputer -SearchBase "CN=Computers,DC=ginaz,DC=org" -Filter * |
ForEach-Object {
    Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Workstations,DC=ginaz,DC=org"
}

# Enable Remote Desktop for local Administrator login
# Ensure that RDP is enabled
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0

# Enable the local Administrator account
Enable-LocalUser -Name "Administrator"

# Add the local Administrator account to the "Remote Desktop Users" group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Administrator"

# Set the Administrator password
$password = ConvertTo-SecureString "Chalc0pyr1te!123" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password