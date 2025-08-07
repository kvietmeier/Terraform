### Create Custom GCP Firewall Rules

This set of rules will open a specific set of ports for common services and additional ports for applications, and filter incoming traffic on public interfaces to specific IPs and/or IP ranges.

It is written to allow you to easily and quickly update the FW rules as your local IP changes (hotel, coffee shop, etc.) or you need to allow additional people into your VPC.

The ingress rules and VAST Data IP/UDP ports are excluded from GitHub by placing them in a separate private.auto.tfvars file, which is not committed to version control.

---

#### How to Use

1. Create Your Private Variables File:
   Create a new file named `private.auto.tfvars` in the same directory as `fw.main.tf`.
2. Add `private.auto.tfvars` to `.gitignore`.
3. Add Your Sensitive Data:
   In the `private.auto.tfvars` file, add your list of private IP addresses and ranges:

```hcl
   ingress_filter = [
   "123.45.67.89/32",  # Example: My Local IP
   "192.0.2.0/24",     # Example: My Office CIDR
   # ... add other private IPs here ...
   ]
```

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
