### Static IP Assignment with `cidrhost()`

This configuration dynamically assigns static private IP addresses to VMs based on their position in a generated list of names. The key line is:

```hcl
network_ip = cidrhost(
  data.google_compute_subnetwork.my_subnet.ip_cidr_range,
  var.ip_start_offset + index(local.vm_names, each.value)
)


### Explanation of Static IP Assignment with `cidrhost()`

| Expression                                               | Purpose                                                                                   |
|----------------------------------------------------------|-------------------------------------------------------------------------------------------|
| `cidrhost(cidr, hostnum)`                                | Terraform function that calculates an IP address within a CIDR block by adding `hostnum`  |
| `data.google_compute_subnetwork.my_subnet.ip_cidr_range` | The subnet CIDR range, e.g., `"10.1.4.0/24"`                                              |
| `var.ip_start_offset`                                    | The starting offset within the subnet to assign IPs (e.g., 90 means starting at `.90`)    |
| `index(local.vm_names, each.value)`                      | Finds the position (0-based index) of the current VM name in the `vm_names` list          |
| `var.ip_start_offset + index(...)`                       | Adds the index to the starting offset to get the host number for the IP                   |
| `cidrhost(...)`                                | Combines the subnet and calculated host number to return the final static IP address      |

---

### Example

Assuming:

| Variable          | Value                              |
|-------------------|----------------------------------|
| `vm_names`        | `["linux01", "linux02", "linux03"]` |
| `ip_start_offset` | `90`                             |
| `subnet CIDR`     | `"10.1.4.0/24"`                  |

The assigned IP addresses will be:

| VM Name   | Index | Host Offset | Assigned IP  |
|-----------|--------|-------------|--------------|
| linux01   | 0      | 90          | 10.1.4.90    |
| linux02   | 1      | 91          | 10.1.4.91    |
| linux03   | 2      | 92          | 10.1.4.92    |

---

### Benefits

- Predictable, consistent IP assignment without hardcoding
- Dynamic scaling based on VM count
- Clear relationship between VM name and IP address

> Adjust `ip_start_offset` to avoid network or reserved addresses.
