### GCP DNS Forwarding Zone for Active Directory

Provisions a **Cloud DNS private forwarding zone** in **Google Cloud Platform (GCP)**. It's typically used to forward DNS queries for an **Active Directory (AD)** domain (e.g., `example.ad.`) to an on-premises or cloud-based DNS server such as one hosted on a **VAST Data cluster** or a domain controller running in a VM.

---

#### Notes

- [GCP: Private DNS Zones](https://cloud.google.com/dns/docs/zones#private)

#### Requirements

- Google Cloud Project with DNS API enabled
- Appropriate IAM permissions to create Cloud DNS zones
- Terraform v1.3+ and Google provider configured

---

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
