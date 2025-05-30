###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


###===================================================================================###
#     Start creating resources
###===================================================================================###

# Google Cloud Service Account for GKE to access GCS
resource "google_service_account" "gke_gcs_access_sa" {
  account_id   = "gke-gcs-access-sa"
  display_name = "GKE Service Account for GCS Access"
  project      = var.project_id
}

# Grant the Service Account the necessary permissions to access the GCS bucket
resource "google_project_iam_member" "gke_gcs_access_sa_storage_bucket_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin" # Or roles/storage.objectViewer, roles/storage.objectCreator, etc.
  member  = "serviceAccount:${google_service_account.gke_gcs_access_sa.email}"
}
