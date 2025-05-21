###===================================================================================###
#
#  File:  vipsnviews.outputs.tf
#  Created By: Karl Vietmeier
#
#     Data Sources & Output
# 
###===================================================================================####

# Output the VIP Pool name and ID
output "vip_pool_existing_name" {
  value = var.vip_pool_existing
}

output "vip_pool_id" {
  value = data.vastdata_vip_pool.protocolsVIP.id
}

# Output the view policy name and ID
output "view_policy_name" {
  value = vastdata_view_policy.vpolicy1.name
}

output "view_policy_id" {
  value = vastdata_view_policy.vpolicy1.id
}

# Output view paths and their associated policies
output "view_paths" {
  value = [
    for i in vastdata_view.nfs_views : {
      path      = i.path
      policy_id = i.policy_id
    }
  ]
}
