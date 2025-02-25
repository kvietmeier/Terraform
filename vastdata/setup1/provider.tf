###
###======================= Confgure vAST Cluster Provider =======================###
###

# Define the required providers
terraform {
    required_version = ">=1.4"

    required_providers {
      vastdata = {
        source  = "vast-data/vastdata"
    }
  }
}

# Provider Configuration
provider vastdata {
  username = var.vast_user
  port = var.vast_port
  password = var.vast_passwd
  host = var.vast_host
  skip_ssl_verify = var.skip_ssl
  version_validation_mode = var.validation_mode
}
