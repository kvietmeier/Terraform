## VAST Data Terraform Template: Views, Policies & Block Storage

This repository provides a standardized, production-ready Terraform template for managing storage endpoints and access controls on **VAST Data** clusters. It contains the complete schema definition for the views, policies, and block resources.  
It is not intended for use "as is" it is designed as a temnplate and reference to use in complete cluster configurations.  

---

## Table of Contents

- **View Policies** (`vastdata_view_policy`): Permission rules, audit settings, and security flavors for NFS, SMB, and S3 protocols.
- **Views** (`vastdata_view`): File exports, buckets, and shares mapped to specific paths and policies.
- **Block Hosts** (`vastdata_block_host`): SAN client host definitions and initiator mappings (iSCSI IQNs, FC WWPNs, NVMe NQNs).
- **Block Host Mappings** (`vastdata_block_host_mapping`): LUN attachments linking block hosts to VAST volumes.

---

### Architecture & Code Structure

The project is structured into 4 primary Terraform files:

```text
├── README.md
├── views.provider.tf
├── views.main.tf          # Core Terraform resource blocks and dynamic linkages
├── views.variables.tf     # Typed schema definitions for all parameters
└── views.auto.tfvars      # Environment-specific values and default parameters
```

---
