###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure GCP Provider
# 
###===================================================================================###

/*
locals {
 terraform_service_account = "karlv-servacct-tform@clouddev-itdesk124.iam.gserviceaccount.com"
}
*/

/*
# Get access token
data "google_service_account_access_token" "default" {
  provider               	= google.impersonation
  target_service_account 	= "karlv-servacct-tform@clouddev-itdesk124.iam.gserviceaccount.com"
  scopes                 	= ["userinfo-email", "cloud-platform"]
  lifetime               	= "1200s"
}
*/

terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
 alias = "impersonation"
 scopes = [
   "https://www.googleapis.com/auth/cloud-platform",
   "https://www.googleapis.com/auth/userinfo.email",
 ]
}

# Configuration Options:
provider "google" {
  project = "clouddev-itdesk124"
  region  = "us-west2"
  zone    = "us-west2-a"
  #impersonate_service_account = "karlv-servacct-tform@clouddev-itdesk124.iam.gserviceaccount.com"
}

