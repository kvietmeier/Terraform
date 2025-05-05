###===================================================================================###
###                       Confgure VAST Cluster Provider   
###===================================================================================###

# Terraform version and required providers
terraform {
    required_version = ">=1.4"

    required_providers {
      vastdata = {
        source  = "vast-data/vastdata"
        version = "1.6.0"
    }
  }
}

# VAST Data Provider Configuration
provider vastdata {
  # Set values in .tfvars
  username                = var.vast_user
  port                    = var.vast_port
  password                = var.vast_passwd
  host                    = var.vast_host
  skip_ssl_verify         = var.skip_ssl
  version_validation_mode = var.validation_mode
  alias                   = "GCPCluster"
}
