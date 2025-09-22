###===================================================================================###
# Terraform Configuration File
#
# Description: Assigns IAP user access roles for Google Cloud VMs
#              - Grants IAP tunnel access at the project level for a list of users
#              - Grants Compute Viewer role at the project level for a list of users
#              - Grants OS Login External User role at the instance level for each user-instance pair
#
# Author:      Karl Vietmeier
# License:     Apache 2.0
#
# Usage:
#  - Configure project_id, user_emails, and instances variables
#  - Run `terraform init` and `terraform apply`
#
# Notes:
#  - `roles/iap.tunnelResourceAccessor` must be assigned at the project level
#  - `roles/compute.osLoginExternalUser` must be assigned per instance
#  - Ensure instance names and zones are accurate to avoid 404 errors
#
#
# Connect to VM with:
# gcloud compute ssh USERNAME@INSTANCE_NAME --zone=ZONE --ssh-key-file=/path/to/private_key.pem --tunnel-through-iap
#
# gcloud compute ssh labuser1@devops01 --zone=us-west2-a --ssh-key-file= --tunnel-through-iap
#
###===================================================================================###


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

# Assign iap.tunnelResourceAccessor at project level for all users
resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

# Assign compute.viewer at project level
resource "google_project_iam_member" "compute_viewer" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.viewer"
  member   = "user:${each.value}"
}

/* # Assign Compute Instance Admin at project level (allows setting metadata)
#compute.instances.setMetadata
resource "google_project_iam_member" "compute_instance_admin" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.instanceAdmin.v1"
  member   = "user:${each.value}"
}

 */

/*
# Has to be set at the Organization level
resource "google_project_iam_member" "oslogin" {
  for_each = toset(var.user_emails)
  project  = var.project_id
  role     = "roles/compute.osLoginExternalUser"
  member   = "user:${each.value}"
}
 */

/* 
Refactor - to use a list - 
This revised code block creates a unique key for each combination of user and role 
(e.g., user1@example.com:roles/iap.tunnelResourceAccessor), which allows for_each to 
correctly create a separate google_project_iam_member resource for every single assignment.

 # Define a list of roles to assign
locals {
  roles_to_assign = [
    "roles/iap.tunnelResourceAccessor",
    "roles/compute.viewer"
  ]
}

# Assign roles to all users using a single resource block
resource "google_project_iam_member" "user_roles" {
  for_each = toset([
    for user in var.user_emails :
    for role in local.roles_to_assign : "${user}:${role}"
  ])

  project = var.project_id
  role    = split(":", each.key)[1]
  member  = "user:${split(":", each.key)[0]}"
} */