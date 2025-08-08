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
        for inst in var.instances : {
          user     = user
          instance = inst.name
          zone     = inst.zone
        }
      ]
    ]) :
    "${pair.user}-${pair.instance}" => pair
  }
}

resource "google_compute_instance_iam_member" "vm_tunnel" {
  for_each      = local.user_instance_pairs
  project       = var.project_id
  zone          = each.value.zone
  instance_name = each.value.instance
  role          = "roles/iap.tunnelResourceAccessor"
  member        = "user:${each.value.user}"
}

resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

resource "google_project_iam_member" "compute_viewer" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.viewer"
  member   = "user:${each.value}"
}

resource "google_project_iam_member" "oslogin" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.osLoginExternalUser"
  member   = "user:${each.value}"
}
