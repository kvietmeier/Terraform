###===================================================================================###
#
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
#     Create a View Policy amd a View
# 
###===================================================================================###

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "1.4.0"
    }
  }
}

provider "vastdata" {
  username                = "admin"
  port                    = "443"
  password                = "123456"
  host                    = "10.100.2.30"
  skip_ssl_verify         = true
  version_validation_mode = "warn"
  alias                   = "GCPCluster"
}
/* 
provider "vastdata" {
  username                = "admin"
  port                    = 443
  password                = "123456"
  host                    = "10.100.2.10"
  skip_ssl_verify         = true
  version_validation_mode = "warn"
  alias                   = "RemoteCluster"
}

 */
###=================================================
data "vastdata_vip_pool" "pool1_gcp" {
  provider = vastdata.GCPCluster
  name     = "protocolsPool"
}

###
output "vip_pool_id_gcp" {
  value = data.vastdata_vip_pool.pool1_gcp.id
}

output "vip_pool_name_gcp" {
  value = data.vastdata_vip_pool.pool1_gcp.name
}


/* 
data "vastdata_vip_pool" "pool1_remote" {
  provider = vastdata.RemoteCluster
  name     = "replicationPool"
}

output "vip_pool_id_remote" {
  value = data.vastdata_vip_pool.pool1_remote.id
}

output "vip_pool_name_remote" {
  value = data.vastdata_vip_pool.pool1_remote.name
} 
*/
