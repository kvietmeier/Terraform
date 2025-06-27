### GCP DNS Forwarding Zone for a VAST Data Cluster

Provisions a **Cloud DNS private forwarding zone** in **Google Cloud Platform (GCP)**. It's used to forward DNS queries for a **VAST Data Cluster** domain (e.g., `vastdata.com.`).

---

#### Notes

- [GCP: Private DNS Zones](https://cloud.google.com/dns/docs/zones#private)

#### Requirements

- Google Cloud Project with DNS API enabled
- Appropriate IAM permissions to create Cloud DNS zones
- Terraform v1.3+ and Google provider configured
- DNS confiogured on a VAST Cluster

---

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
