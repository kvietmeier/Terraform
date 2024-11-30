### Windows startup script for Terraform
$Password       = "Chalc0pyr1te!123"
$securePassword = ConvertTo-SecureString -AsPlainText $Password -Force

# LZ31h=*kjG+nHRH

# Enable Administrator account and set password
#$UserAccount    = Get-LocalUser -Name "Administrator" 
#Enable-LocalUser -Name $UserAccount.name
#Set-LocalUser -Name $UserAccount.name -Password $securePassword

# Set the karl_vietmeier users password
#$UserAccount = Get-LocalUser -Name "karl_vietmeier"
#Set-LocalUser -Name $UserAccount.name -Password $securePassword



# List of users and their passwords
$Users = @(   
    @{ Username = "labuser01"; Password = $securePassword },
    @{ Username = "labuser02"; Password = $securePassword },
    @{ Username = "labuser03"; Password = $securePassword }
)

# Create users
foreach ($User in $Users) {
    try {
        # Create the local user account
        New-LocalUser -Name $User.Username -Password $User.Password -FullName $User.Username -Description "Created via PowerShell" -AccountNeverExpires
        
        # Add the user to the Administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $User.Username

        Write-Host "Successfully created user: $($User.Username)" -ForegroundColor Green
    } 
    catch { Write-Host "Failed to create user: $($User.Username). Error: $_" -ForegroundColor Red }
}


#$params = @{
#    Name        = 'labuser10'
#    Password    = $securePassword
#    FullName    = 'Lab User01'
#    Description = 'User for benchmarking'
#}
#New-LocalUser @params

# Download Chrome Installer
$chromeInstaller = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
$outputPath = "C:\Windows\Temp\chrome_installer.exe"
Invoke-WebRequest -Uri $chromeInstaller -OutFile $outputPath

# Install Chrome Silently
Start-Process $outputPath -ArgumentList "/silent /install" -Wait

# Clean up installer
Remove-Item $outputPath

# Disable Server Manager:
#$RegPath = 'HKCU:\Software\Microsoft\ServerManager'

# Add and set Key
#New-Item -Path $RegPath -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "0x1" –Force
#New-ItemProperty -Path $RegPath -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "0x1" –Force

# Change value
#New-ItemProperty -Path $RegPath -Name CheckedUnattendLaunchSetting -PropertyType DWORD -Value "0x0" -Force

# Disable Server Manager at logon
$RegPath = 'HKCU:\Software\Microsoft\ServerManager'

# Ensure the registry key exists
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Add or set registry values
Set-ItemProperty -Path $RegPath -Name DoNotOpenServerManagerAtLogon -Value 1 -Type DWORD -Force
#Set-ItemProperty -Path $RegPath -Name CheckedUnattendLaunchSetting -Value 0 -Type DWORD -Force

Write-Host "Server Manager has been disabled for logon." -ForegroundColor Green