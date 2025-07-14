###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VM Info
vm_name         = "rocky-01"
machine_type    = "e2-medium"
#os_image        = "centos-stream-9-v20241009"
os_image        = "rocky-linux-9-optimized-gcp-v20240815"
bootdisk_size   = "60"
ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCR3kYosYelwdlVg3LBDokW4BOYMLE/dmH4YeCDkEPxUIgpKOPU9ipXJO3ZtSIjRkNfEoI25ScRJSYA+ZkrpeTypJSAF1mCU8GDgUbtJmFqAzTLfhZdXVdXOEEXdN1feVixc/mfK+qkS2GxAwL+Y64E/HdKgZ8Kdh2FZfeHzAwe3CPBcAxfbjCgaebvc9PLBq5fApvB1hUUUPa+74OeXGAYJFDdq6i0ip+dPEUlPh9fMEvo1LiSMIQZucw4yy+qXc0I7zHVCQwnFYD9D5xdmUMRADF0x3C/wh1wRzY+Rj2c3FzV98iAICIVdZSoMU25G58myMZv6vXHFW+x6spW/Z/BgiEerL7/lb0VL26UrUtVfoEzESMuTVHdhVUpPDzi615ypumsqhxHijsRCJHkaCkbYRb8w193r9lJ+XjrAm/YieM43LZIC15sdp5bVtokifDor8IAGj+uw6z+Zrbaz9/Q8kQfx7ykASql6WAlgROJ4fJJXPl2f6AoLjhI1ylUUH8= karl.vietmeier@linuxtools"
ssh_key_file    = "../../../secrets/karl.vietmeier.x1.pub"
ssh_user        = "adminuser"

ssh_keys_map = {
  # Linux Tools
  adminuser = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCR3kYosYelwdlVg3LBDokW4BOYMLE/dmH4YeCDkEPxUIgpKOPU9ipXJO3ZtSIjRkNfEoI25ScRJSYA+ZkrpeTypJSAF1mCU8GDgUbtJmFqAzTLfhZdXVdXOEEXdN1feVixc/mfK+qkS2GxAwL+Y64E/HdKgZ8Kdh2FZfeHzAwe3CPBcAxfbjCgaebvc9PLBq5fApvB1hUUUPa+74OeXGAYJFDdq6i0ip+dPEUlPh9fMEvo1LiSMIQZucw4yy+qXc0I7zHVCQwnFYD9D5xdmUMRADF0x3C/wh1wRzY+Rj2c3FzV98iAICIVdZSoMU25G58myMZv6vXHFW+x6spW/Z/BgiEerL7/lb0VL26UrUtVfoEzESMuTVHdhVUpPDzi615ypumsqhxHijsRCJHkaCkbYRb8w193r9lJ+XjrAm/YieM43LZIC15sdp5bVtokifDor8IAGj+uw6z+Zrbaz9/Q8kQfx7ykASql6WAlgROJ4fJJXPl2f6AoLjhI1ylUUH8= karl.vietmeier@linuxtools"
  # Karl Laptop
  adminuser = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOVhK8T5vJgKqXzSgDryh1EQEReE1lU9CvlBK8v4bG+eTjhPqacXqPkUWPlnM+kA1l3xe/GBxbIeoJ/WruUZV58SBjUUEMYN0qyKVwl+G5GqhijGAsWNC1KsfpTHNRRplZWAkKajAzb57kCzdNvFmOi86ENhn4gYFTWqAPEYALMnq6T1D52SELJGs/A3fwDEE99nTjcZ4/Huv1z+WWJmZEkSRWNtYLD/mx+cP41UHKCEIgsffvKH3o/IHgpsDGi5sQ8AKHChNkHb3vWQVPHx1BZDwxEUG7SPjY4gc/wRtrdauzMvdKvm9AUi1paY2PCGViLcysv619hQj02k/OQBJBy7MqplB1waoisxDuxKMSKjeKTyMGbMfv+MCrQd1iT+qdQtQImvyxRtQnYnbNMjnLPYUey7/kTkb4Xggm/hhuJOxnFqH/9WILDb81I4jElis+raXh0Vnt7gQ7OAO74osiLqD7uGuhytRCLqnU5VQmEAGdpxahxtirRu0eVQr/Ncs= karl.vietmeier@Tandaloor"
  # Karl WSL
  adminuser = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMceaE7F8yL6822ZLagNh7atSdxiGmaurxA0BMP2pmwy1BTH/vAkj9ZU30+qZ5IvHiOS+WzAWmd02X49D57g25wQMFpL7YQrWlzdidhymFa/WsXfSJtb23n6WBvt8cm2uHxV2WZwRVwc2z3GSgM42fwCuOCQTglWlZqs6Fpkhr3hlfI/8uMWwfXbX7NZ/kIb6zxBzUQlJHPAE4naKtKCAe76DI12SGMDazQaPrZ1SFaxkDK4D7I3SN8MzVFOxFVErHwlp1shXx7R9fL9NXH3r7WryRFL1py56z7VWweKNiWx22iAST0ySUgZyL0GYSVd0xep7KWDc07xNl5Th3ytsN3vA6h8nKiCz0TNEDC3CmxLZrAa6xt4DUEi6LXtUdzFvueaGXjVi8OfTpCvlo46bRhYGrfkFP1OhyR5YE9wzw0g+h4q+qMZs4LRJVeLfnwUtwQCpGMkZXn0i/UYwO1n+lGkvi+a8mYu28N2AxPYVP6wDAFbB4ryyUlsCaMnGbids= karlv@Tandaloor"
}

# VPC Config - existing
vpc_name        = "default"
subnet_name     = "infrasubnet01"
