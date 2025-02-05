###======================================================================================================###
###
###                               Windows setup script for Terraform
###
###
###
###
###======================================================================================================###

# Set TZ correctly
#Set-TimeZone -Name "Pacific Standard Time"


###========================================     Setup Users     =========================================###
$Password       = "Chalc0pyr1te!123"
$securePassword = ConvertTo-SecureString -AsPlainText $Password -Force

# Enable Administrator account and set password
# Set the password for Administrator
Get-LocalUser -Name "Administrator" | Enable-LocalUser
Set-LocalUser -Name "Administrator" -Password $securePassword

#$UserAccount    = Get-LocalUser -Name "Administrator" 
#Enable-LocalUser -Name $UserAccount.name
#Set-LocalUser -Name $UserAccount.name -Password $securePassword


# List of users to create and their passwords
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


###========================================     Install Software      =========================================###
###---  Chrome
# Download Chrome Installer
$chromeInstaller = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
$outputPath = "C:\Windows\Temp\chrome_installer.exe"
Invoke-WebRequest -Uri $chromeInstaller -OutFile $outputPath

# Install Chrome Silently
Start-Process $outputPath -ArgumentList "/silent /install" -Wait

# Clean up installer
Remove-Item $outputPath

###--- Install necessary packages
#Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeManagementTools -IncludeAllSubFeature -Verbose



###========================================     Registry Settings     =========================================###
###--- Registry Keys to create or set
$RDPRegPath     = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
$TaskBarReg     = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$ServMgrRegPath = 'HKLM:\Software\Microsoft\ServerManager'
#$CURegPath = 'HKCU:\Software\Microsoft\ServerManager'

###--- Add or set registry values

<# # Define an array of variable names
$RegKeys = @("RDPRegPath", "TaskBarReg", "ServMgrRegPath") 

# Loop through the array of variable names
foreach ($Key in $RegKeys) {
    # Get the value of the current variable 
    $RegPath = Get-Variable -Name $Key -ValueOnly

    # Perform actions with the variable value
    Write-Host "Variable Name: $Key"
    Write-Host "Variable Value: $RegPath" 
    # Add more actions here, such as:
    # - Check if the variable is null or empty
    # - Compare the variable value to another value
    # - Use the variable value in a calculation or command
   
   if (-not (Test-Path $Key)) {
      New-Item -Path $RegPath -Force | Out-Null
   } 
   else 
   {
      write-host "$RegPath exists"
   }
}
#>

# Disable Server Manager at logon for everyone
Set-ItemProperty -Path $ServMgrRegPath -Name "DoNotOpenServerManagerAtLogon" -Value 1 -Type DWORD -Force

# RDP Timeouts
Set-ItemProperty -Path $RDPRegPath -Name "MaxIdleTime" -Type "DWORD" -Value "14400000" # 4hrs -Force
Set-ItemProperty -Path $RDPRegPath -Name "MaxDisconnectionTime" -Type "DWORD" -Value "14400000"   # 4hrs -Force 

# Make Taskbar Icons small
New-Itemproperty -Path $TaskBarReg -Name TaskbarSmallIcons -PropertyType DWORD -Value 1 -Force


###======================================================================================================###
###                                      System Tuning
###======================================================================================================###
# DisableBandwidthThrottling
# HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\DisableBandwidthThrottling
# The default is 0
# Consider setting this value to 1

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "DisableBandwidthThrottling" -PropertyType DWORD -Value 1 `
    -Force    

# FileInfoCacheEntriesMax
# HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\FileInfoCacheEntriesMax
# The default is 64
# Try increasing this value to 1024

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "FileInfoCacheEntriesMax" -PropertyType DWORD -Value 1024 `
    -Force    

# DirectoryCacheEntriesMax
# HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\DirectoryCacheEntriesMax
# The default is 16
# Consider increasing this value to 1024

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "DirectoryCacheEntriesMax" -PropertyType DWORD -Value 1024 `
    -Force    

# FileNotFoundCacheEntriesMax
# HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\FileNotFoundCacheEntriesMax
# The default is 128
# Consider increasing this value to 2048

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "FileNotFoundCacheEntriesMax" -PropertyType DWORD -Value 2048 `
    -Force    

# DormantFileLimit
# HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\DormantFileLimit
# The default is 1023
# Consider reducing this value to 256

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "DormantFileLimit" -PropertyType DWORD -Value 256 `
    -Force    

###---- End Tuning