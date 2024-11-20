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
