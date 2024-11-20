# Get the list of instances
$instances = gcloud compute instances list --format="value(name,networkInterfaces[0].networkIP,zone)"

# Check if instances were found
if ($instances -eq "") {
    Write-Host "No instances found."
    exit 1
}

# Process each instance's details
# Process each instance's details
$instances.Split("`n") | ForEach-Object {
    $details = $_ -split '\s+'  # Split by one or more whitespace characters
    $name = $details[0]
    $ip = $details[1]
    $zone = $details[2]
    
    # Construct the private DNS name based on your domain naming convention
    $privateDns = "$name.c.clouddev-itdesk124.internal"
    
    # Output the VM details
    Write-Host ""
    Write-Host "VM Name: $name"
    Write-Host "Private DNS: $privateDns" -ForegroundColor Magenta
    Write-Host "Private IP: $ip"
    #Write-Host "Zone: $zone"
    Write-Host ""
    #Write-Host "---------------------------"
}