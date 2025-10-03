#  Active Directory integration Notes

### Getting Active Directory Information for Configuring a Cluster

Sometimes it can be difficult to get the exact information you need through GUIs or asking questions. Fortunately there are a few PowerShell commands you can use.  

You need (example values):

```hcl
ou_name         = "voc-cluster01"
ad_ou           = "OU=VAST,DC=ginaz,DC=org "
bind_dn         = "CN=Administrator,CN=Users,DC=ginaz,DC=org"
bindpw          = "Chalc0pyr1te!123"
ad_domain       = "ginaz.org"
```
  
The sequence of PowerShell commands below will extract this in a usable form from a Domain Controller.   
**NOTE:** You will need the AD PowerShell Modules but most AD domain controllers should have them installed, and must run them in an Admin console.    

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

#### For Extra Credit  
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

###  Key Resources

| Resource                              | Purpose                                           |
|---------------------------------------|---------------------------------------------------|
| `vastdata_active_directory2`          | Configure Active Directory Domain integration     |
|---------------------------------------|---------------------------------------------------|

---

#### Author

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

#### Acknowledgments

* Josh Wentzel for getting me started down this path.
