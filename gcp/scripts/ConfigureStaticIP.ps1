###========================================================================================###
###           
###  Set the interface to a static IP
###
###========================================================================================###

# Define the network interface card (NIC) name
$nicName = "Ethernet" # Replace with the actual name of your NIC

# IP Settings
$IPAddr     = "10.111.1.5"
$DefGateway = "10.111.1.1"
$DNSServer1 = "127.0.0.1"

# Get the NIC object
$nic = Get-NetAdapter | Where-Object {$_.Name -eq $nicName}

# Set the IP address configuration w/255.255.255.0 netmask
$nic | Set-NetIPAddress -IPAddress $IPAddr -PrefixLength 24 -AddressFamily IPv4

# Verify the configuration
Get-NetIPAddress | Where-Object {$_.IPAddress -eq $IPAddr}

# Get the interface index of the network adapter you want to modify
$InterfaceIndex = (Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*"})[0].ifIndex

# Set the new default gateway
New-NetRoute -InterfaceIndex $interfaceIndex -DestinationPrefix 0.0.0.0/0 -NextHop $DefGateway

# Set the DNS server addresses (this breaks connectivity)
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ($dnsServer1)

# Disable DHCP - (broke networking)
#$nic | Set-NetIPInterface -InterfaceAlias $nicName -Dhcp Disabled 
