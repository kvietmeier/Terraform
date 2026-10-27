###===================================================================================###
#
#  File:        lab.outputs.tf
#  Author:      Karl Vietmeier
#
###===================================================================================###

output "lab_share" {
  description = "lab_share view, policy, and optional S3 owner summary"
  value = {
    tenant_id  = data.vastdata_tenant.selected.id
    tenant     = var.tenant_name
    protocols  = var.protocols
    policy_id  = vastdata_view_policy.lab.id
    policy     = vastdata_view_policy.lab.name
    view_id    = vastdata_view.lab_share.id
    path       = vastdata_view.lab_share.path
    share      = local.want_smb ? var.share_name : null
    bucket     = local.want_s3 ? var.bucket_name : null
    bucket_owner = local.want_s3 ? var.lab_user_name : null
    lab_user_id  = local.want_s3 ? vastdata_user.lab[0].id : null
  }
}

output "protocols_vip_pool" {
  description = "Cloud protocols VIP pool bound to lab_policy"
  value = {
    name = data.vastdata_vip_pool.protocols.name
    id   = data.vastdata_vip_pool.protocols.id
  }
}
