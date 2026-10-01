###===================================================================================###
###                       Configure VAST Cluster Provider
###
###  Standardized provider drop-in (from vastdata/provider/).
###  set_var54 / _vast_apply export TF_VAR_vast_* and VASTDATA_*.
###  Wire host/port explicitly so plan does not prompt.
###===================================================================================###

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "3.2.2"
    }
  }
}

# Populated via TF_VAR_* from set_var54 / _vast_apply
variable "vast_host" {
  type = string
}

variable "vast_port" {
  type    = string
  default = "443"
}

variable "vast_username" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_password" {
  type      = string
  default   = null
  sensitive = true
}

# Declared so set_var54's TF_VAR_vast_api_token="" does not warn; unused (simple auth only).
variable "vast_api_token" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_skip_ssl_verify" {
  type    = bool
  default = true
}

variable "vast_version_validation_mode" {
  type    = string
  default = "warn"
}

# Simple auth only (username/password). Do not pass api_token —
# empty TF_VAR_vast_api_token conflicts with password auth on the provider.
#
# tenant must be empty: set_var54 exports VASTDATA_TENANT=default, and the
# provider would otherwise send X-Tenant-Name on login (tenant-admin auth),
# which 401s for cluster admin. Curl works without that header.
provider "vastdata" {
  host                    = var.vast_host
  port                    = tonumber(var.vast_port)
  username                = var.vast_username
  password                = var.vast_password
  tenant                  = ""
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
}
