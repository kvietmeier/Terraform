###===================================================================================###
#  Created By:  Karl Vietmeier
#  Purpose:     De Novo NVIDIA Blackwell Workstation Deployment (Ubuntu 24.04)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
###===================================================================================###

terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}