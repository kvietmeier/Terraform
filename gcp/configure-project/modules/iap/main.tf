###===================================================================================###
#  Module: iap
#  Adapted from gcp/CoreInfra/IAPSetup
###===================================================================================###

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
