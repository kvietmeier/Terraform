#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create Default GCP Firewall Rules

Recreate the default GCP firewall rules

---

#### Notes

Put Notes Here

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#
#  File:  fw_defaults.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create default GCP Firewall rules
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw_defaults.tfvars"
terraform apply --auto-approve -var-file=".\fw_defaults.tfvars"
terraform destroy --auto-approve -var-file=".\fw_defaults.tfvars"

*/

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "google_compute_firewall" "default_allow_internal" {
  name    = "default-allow-internal"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "default_allow_icmp" {
  name    = "default-allow-icmp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}
###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP Provider TerraForm
# 
#  Google defaults set as Env: vars
#
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  Edit as required
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "default"

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


###---  Standard Values
# Project Info
project_id      = "<project ID>"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "default"
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###--- VPC Setup
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "default"
}
