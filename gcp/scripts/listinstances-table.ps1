###====================================================================================###
<#   
  FileName: listinstances-table.ps1
  Created By: Karl Vietmeier
    
  Description:
   Create a table with private IPs and private DNS
   Format - 
   "<vmname>.c.<projectID>.internal"

   Source:  https://cloud.google.com/compute/docs/internal-dns
   
   * gcloud commands
   gcloud compute instances list --format="value(name,networkInterfaces[0].networkIP,zone)"
   gcloud compute instances list --format="table(name, networkInterfaces[0].accessConfigs[0].natIP, networkInterfaces[0].networkIP, zone)"

#>
###====================================================================================###


# Get the list of instances
$instances = gcloud compute instances list --format="value(name,networkInterfaces[0].networkIP,zone)"

# Check if instances were found
if ($instances -eq "") {
    Write-Host "No instances found."
    exit 1
}

# Create a list to hold formatted data for table
$table = @()

# Process each instance's details
# Process each instance's details
$instances.Split("`n") | ForEach-Object {
    $details = $_ -split '\s+'  # Split by one or more whitespace characters
    $name = $details[0]
    $ip = $details[1]
    $zone = $details[2]
    
    # Construct the private DNS name based on your domain naming convention
    $privateDns = "$name.c.clouddev-itdesk124.internal"
    
    # Add formatted object to the table array
    $table += [PSCustomObject]@{
        'VM Name'     = $name
        'Private IP'  = $ip
        'Zone'        = $zone
        'Private DNS' = $privateDns
    }

}

# Output the table with colors using Format-Table
$table | Format-Table -Property 'VM Name', 'Private IP', 'Zone', 'Private DNS' -AutoSize

<## Colorize rows manually
To colorize table-like output manually (e.g., highlighting certain rows or columns), you can iterate
over each row and use Write-Host as shown below:
#>

#$table | ForEach-Object {
#    Write-Host ("VM Name: " + $_.'VM Name') -ForegroundColor Green
#    Write-Host ("Private IP: " + $_.'Private IP') -ForegroundColor Cyan
#    Write-Host ("Zone: " + $_.'Zone') -ForegroundColor Yellow
#    Write-Host ("Private DNS: " + $_.'Private DNS') -ForegroundColor Magenta
#    Write-Host "---------------------------" -ForegroundColor White
#}