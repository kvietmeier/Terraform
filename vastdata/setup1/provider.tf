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
  username = "admin"
  port = "3333"
  password = "123456"
  host = "0.0.0.0"
  skip_ssl_verify = true
  version_validation_mode = "warn"
}
