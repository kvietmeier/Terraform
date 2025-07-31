###===================================================================================###
###                       Confgure VAST Cluster Provider   
###===================================================================================###

# Terraform version and required providers
terraform {
    required_version = ">=1.4"

    required_providers {
      vastdata = {
        source  = "vast-data/vastdata"
        #version = "1.4"
    }
  }
}

# Provider Configuration Cluster A - local in GCP
provider vastdata {
  # Set values in .tfvars
  #alias                   = "GCPCluster"
  alias                   = var.vasta_alias
  username                = var.vasta_user
  port                    = var.vasta_port
  password                = var.vasta_passwd
  host                    = var.vasta_host
  skip_ssl_verify         = var.vasta_skip_ssl
  version_validation_mode = var.vasta_validation_mode
}

# Provider Configuration - Cluster B (remote)
provider vastdata {
  # Set values in .tfvars
  #alias                   = "RemoteCluster"
  alias                   = var.vastb_alias
  username                = var.vastb_user
  port                    = var.vastb_port
  password                = var.vastb_passwd
  host                    = var.vastb_host
  skip_ssl_verify         = var.vastb_skip_ssl
  version_validation_mode = var.vastb_validation_mode
}
