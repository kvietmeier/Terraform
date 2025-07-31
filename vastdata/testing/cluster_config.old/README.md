### VAST Data Cluster Demo/POC Setup

This repository contains Terraform configurations to automate the setup of a basic VAST Data cluster environment for **demo or proof-of-concept (POC)** scenarios. The configuration includes:

- VAST Provider and authentication
- VIP Pools for `PROTOCOLS` and `REPLICATION`
- NFS view policy and NFS views
- S3 view policy and NFS views
- DNS configuration
- Basic multi-tenant setup with users and groups
- Active Directory integration

---

### Prerequisites

- Terraform installed
- VAST provider plugin initialized
- Access to a VAST Data cluster (on GCP or other supported platforms)
- Accessible Active Directory DC
- DNS Forwarder configured to point to the VAST DNS domain/s

### Elements Created

#### Provider Configuration

Establishes a connection to a VAST Data cluster using credentials and API endpoint info.

####  VIP Pools

Defines two VIP Pools:

- `sharesPool`: Assigned the `PROTOCOLS` role
- `targetPool`: Assigned the `REPLICATION` role

####  Tenants, Groups, and Users

- Dynamically creates tenants from a list.
- Groups and users are provisioned with specified GIDs/UIDs and group relationships.

####  View Policy

Creates a VAST NFS view policy with:

- Authentication sources
- Read/write permissions
- VIP pool assignment

####  NFS Views

Provisioned using a loop, each with:

- Path prefix (e.g., `/nfs_share_1`, `/nfs_share_2`)
- Backed by the defined view policy
- Optionally creates a backing directory

####  DNS

Defines a VAST DNS server for the VAST cluster, using the `busab.org` domain suffix and specified VIP address.

####  Active Directory

Configure Active Directory integration to join the `ginaz.org` domain.

---

### Examples

The online documentation doesn't have very good examples of things like DNS and setting up S3 and the LLMs do not have correct information on the Provider. As I figure out how to configure them I will try to put some examples here with explantions.

#### DNS

Setting up DNS is a good example. It isn't immediately clear from the documentation that you need to configure it in 2 places to get a complete implementation.  

- In the DNS resource "*domain_suffix*" is the root domain of the FQDN or properly the "*domain name*":

  ```hcl
  resource "vastdata_dns" "protocol_dns" {
    provider      = vastdata.GCPCluster
    name          = var.dns_name
    vip           = var.dns_vip
    net_type      = var.port_type
    domain_suffix = var.dns_domain_suffix
    enabled       = var.dns_enabled
  }
  ```

- In the VIP Pool resource it can be confusing because the attribute you need to set is named incorrectly - it is called the "*domain_name*" when it is more correctly refered to as the "*short, or host name*". *Not sure it is required but just in case I added a dependency on DNS being setup first*:

  ```hcl
  resource "vastdata_vip_pool" "protocols" {
  provider     = vastdata.GCPCluster
  name         = var.vip1_name
  domain_name  = var.dns_shortname
  role         = var.role1
  subnet_cidr  = var.cidr
  gw_ip        = var.gw1
  ip_ranges {
        start_ip = var.vip1_startip
        end_ip   = var.vip1_endip
    }
    
  depends_on = [vastdata_dns.protocol_dns]
  }
  ```

---

### Getting Active Directory Information for Configuring a Cluster

Sometimes it can be difficult to get the exact information you need through GUIs or asking questions. Fortunately there are a few PowerShell commands you can use.  

You need:

```hcl
ou_name         = "voc-cluster01"
ad_ou           = "OU=VAST,DC=ginaz,DC=org "
bind_dn         = "CN=Administrator,CN=Users,DC=ginaz,DC=org"
bindpw          = "Chalc0pyr1te!123"
ad_domain       = "ginaz.org"
```

The sequemce of PowerShell commands below will extract this in a usable form from a Domain Controller.   
**NOTE:** You will need the AD PowerShell Modules but most AD domain controllers should have them installed, and run in an Admin console.  

- Domain Information

  ```powershell
     PS C:\> (Get-ADDomain).DistinguishedName
     DC=ginaz,DC=org
  ```

- OUs for adding Servers (VAST was added)

  ```powershell
     PS C:\> Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
    
     Name               DistinguishedName                    
     ----               -----------------                    
     Domain Controllers OU=Domain Controllers,DC=ginaz,DC=org
     VAST               OU=VAST,DC=ginaz,DC=org              
  ```

- Find the Admin users

```powershell
    PS C:\> Get-ADGroupMember -Identity "Domain Admins" -Recursive | Select-Object Name, SamAccountName, ObjectClass

    Name          SamAccountName ObjectClass
    ----          -------------- -----------
    Administrator Administrator  user       
```

- Get the Bind DN for an Admin user that can add servers (clusters) to a domain

  ```powershell
      PS C:\> Get-ADUser -Identity "Administrator" | Select-Object DistinguishedName
    
      DistinguishedName                        
      -----------------                        
      CN=Administrator,CN=Users,DC=ginaz,DC=org
  ```

**For Extra Credit**  
If you have access to the Domain Controllers (Lab) or the customer is interested, you can add a new OU for VAST clusters.  

- Create a new OU with a different name (VAST):

  ```powershell
     New-ADOrganizationalUnit -Name "VAST" -Path "DC=ginaz,DC=org"
  ```

- Redirect new VAST Clusters you add to the OU:

  ```powershell
     redircmp "OU=VAST,DC=ginaz,DC=org"
  ```

- Move existing ones to the new OU (careful with this one - it needs to be more selective - use at your own risk):

  ```powershell
      Get-ADComputer -SearchBase "CN=Computers,DC=ginaz,DC=org" -Filter * |
      ForEach-Object {
        Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Workstations,DC=ginaz,DC=org"
      }
  ```

---

### Key Resources

| Resource                              | Purpose                                           |
|---------------------------------------|---------------------------------------------------|
| `vastdata_tenant`                     | Creates tenants (multi-tenant support)            |
| `vastdata_group`                      | Defines user groups                               |
| `vastdata_user`                       | Creates users with group associations             |
| `vastdata_vip_pool`                   | Configures VIP Pools for network access           |
| `vastdata_view_policy`                | View policy for NFS and SMB access                |
| `vastdata_view`                       | Provision of NFS views                            |
| `vastdata_dns`                        | DNS setup for VAST domain resolution              |
| `vastdata_active_directory2`          | Configure Active Directory Domain integration     |

---

#### Author

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

#### Acknowledgments

- Josh Wentzel for getting me started down this path.
