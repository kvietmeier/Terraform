<####################################################################################
  Created By:
    Karl Vietmeier
  
  Purpose:
    Download and install/upgrade Terraform
  
  Assumes:
    * You want to use C:\Temp as a target
    * You have a C:\Users\$UserName\bin dir for standalone binaries
  
  Vault URL:
  https://releases.hashicorp.com/vault/1.16.2/vault_1.16.2_windows_amd64.zip

  ToDo:
  Add code to download/upgrade Vault

####################################################################################>

# Just to be sure while testing
# --- Make sure your vars are right then uncomment
#return

# What version are we downloading?
$TFVer    = "1.6.6"
$TFUrl    = "https://releases.hashicorp.com/terraform/"
$VaultVer = "1.16.2"
$VaultURL = "https://releases.hashicorp.com/vault/"

# Uncomment to get all of the available versions:
#$TFVersions = Invoke-WebRequest 'https://releases.hashicorp.com/terraform/' -UseBasicParsing
#$TFVersions.Links.HREF

# These can change -  Get username from who is running this
# I use a "bin" folder in $PATH for standalone binaries
$DownloadDir = "C:\temp"
$BinDir      = "C:\Users\" + $env:UserName + '\bin'

# These are built based on first 3 above
$TFModuleURL   = $TFUrl + $TFVer + '/terraform_' + $TFver + '_windows_amd64.zip'
$TFZip         = $DownloadDir + '\terraform_' + $TFver + '_windows_amd64.zip'
$TFExtractDir  = $DownloadDir + '\tf'
$TFDlbin       = $TFExtractDir + '\terraform.exe'
$TFTargetbin   = $BinDir + '\terraform.exe'

# Check to see if C:\temp exists - if not create it
if (!(Test-Path $DownloadDir))
{
  Write-Host "Creating C:\temp"
  New-Item -ItemType Directory -Force -Path $DownloadDir
  # I use C:\Temp for stuff - don't want to whack it - you might
  #$removeDir = "False" # We created it, so remove it afterward
}

# Grab and expand Terraform I'm just overwriting existing right now.
if (!(Test-Path -Path $TFDlbin -PathType Leaf))
{
  Write-Host "No Terraform binary in DowloadDir - Extracting new Terraform binary"
  Invoke-WebRequest -Uri $TFModuleURL -OutFile $TFZip
  Expand-Archive -LiteralPath $TFZip -DestinationPath $TFExtractDir
}
elseif (Test-Path -Path $TFDlbin -PathType Leaf) {
  Write-Host "Terraform binary already in DownloadDir - Overwriting with new Terraform binary"
  Invoke-WebRequest -Uri $TFModuleURL -OutFile $TFZip
  Expand-Archive -LiteralPath $TFZip -DestinationPath $TFExtractDir -Force
}


# Does the binary already exist
if (!(Test-Path -Path $TFTargetbin -PathType Leaf))
{
  Write-Host "No Terraform binary in BinDir - Installing new Terraform binary"
  Move-Item -Path $TFDlbin -Destination $TFTargetbin -Force
  #New-Item -ItemType Directory -Force -Path $DownloadDir
  #$removeDir = "False" # We created it, so remove it afterward
}
elseif (Test-Path -Path $TFTargetbin -PathType Leaf) {
  Write-Host "Terraform binary already in BinDir - Installing new Terraform binary"
  Move-Item -Path $TFDlbin -Destination $TFTargetbin -Force
}

# Cleanup the download
Remove-Item $TFZip

<# 
# Don't always do this - 
if ($removeDir = "True")
{
  Write-Host "Removing C:\temp"
  Set-Location "C:\"
  Remove-Item -Recurse $DownloadDir
}
#>