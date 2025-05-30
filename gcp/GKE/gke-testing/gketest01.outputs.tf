###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


# Output the cluster name for easy access
output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}

# Output the cluster location
output "cluster_location" {
  value       = google_container_cluster.primary.location
  description = "The location of the GKE cluster."
}

# Output kubeconfig instructions
output "kubeconfig_instructions" {
  value = "To connect to your cluster, run: gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.project_id}"
  description = "Instructions to configure kubectl for the GKE cluster."
}

output "gke_gcs_access_sa_email" {
  value       = google_service_account.gke_gcs_access_sa.email
  description = "Email of the GSA for GKE GCS access."
}