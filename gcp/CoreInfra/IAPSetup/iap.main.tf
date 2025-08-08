###===================================================================================###
#  Terraform Configuration File
#
#  Description : Setup IAP User Roles
#  Author      : Karl Vietmeier
#
#  License     : Apache 2.0
#
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###o


# Flatten user–instance pairs into a map
locals {
  user_instance_pairs = {
    for pair in flatten([
      for user in var.user_emails : [
        for instance in var.instance_names : {
          user     = user
          instance = instance
        }
      ]
    ]) :
    "${pair.user}-${pair.instance}" => pair
  }
}

resource "google_compute_instance_iam_member" "jump_host_tunnel" {
  for_each      = local.user_instance_pairs
  project       = var.project_id
  zone          = var.zone
  instance_name = each.value.instance
  role          = "roles/iap.tunnelResourceAccessor"
  member        = "user:${each.value.user}"
}


# Project-level IAP tunnel access
resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

# Optional: Let gcloud look up instance metadata
resource "google_project_iam_member" "compute_viewer" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.viewer"
  member   = "user:${each.value}"
}

# OS Login for guest OS (only if enabled)
resource "google_project_iam_member" "oslogin" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.osLoginExternalUser"
  member   = "user:${each.value}"
}