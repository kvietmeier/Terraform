# VAST Data Cluster Demo/POC Setup

## Baseline Configuration of a VAST Data Cluster from Scratch

---
---

### Overview

This project contains Terraform a configuration to automate the setup of a complete VAST Data cluster suitable for **demo or proof-of-concept (POC)** scenarios. The configuration includes:

- VAST Provider and authentication
- NFS view policy and NFS views
- S3 view policy and NFS views
- S3 View for Database
- Creates empty database instance
- S3 User policies
- Basic tenant setup with users and groups

---

### Prerequisites

- Terraform installed
- VAST provider plugin initialized
- Access to a VAST Data cluster (on GCP or other supported platforms)

### Elements Created

#### Provider Configuration

Establishes a connection to a VAST Data cluster using credentials and API endpoint info.

#### Tenants, Groups, and Users

- Dynamically creates tenants from a list.
- Groups and users are provisioned with specified GIDs/UIDs and group relationships.
- S3 users have keys uploaded

#### NFS View Policy

Creates a VAST NFS view policy with:

- Authentication sources
- Read/write permissions
- VIP pool assignment (TBD)

#### NFS Views

Provisioned from a list where each view can be configured uniquely

#### S3 View Policy

Basic policy with no extra settings

#### S3 Views

- 2 views - one for standard S3, one for Database

#### S3 User Policies

- Sample configurations loaded from json files in ../policies

#### S3 User Keys

- Add PGP key for S3
- Use local script to recover the keys

#### Database

- Created when you add "DATABASE" to an S3 View - named after the bucket

---
---

### Author

- **Karl Vietmeier**

### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

### Acknowledgments

- Josh Wentzel for getting me started down this path.
