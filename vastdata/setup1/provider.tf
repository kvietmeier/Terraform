###
###======================= Confgure Provider =======================###
###


terraform {
    required_version = ">=1.4"

    required_providers {
      vastdata = {
        source  = "vast-data/vastdata"
    }
  }
}

provider vastdata {
  username = "admin"
  port = "3333"
  password = "123456"
  host = "0.0.0.0"
  skip_ssl_verify = true
  version_validation_mode = "warn"
}
