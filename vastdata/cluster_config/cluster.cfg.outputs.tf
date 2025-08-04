###===================================================================================###
#   Vast Data Cluster Configuration Outputs
###===================================================================================###


# S3 Keys for s3user1
output "s3_access_key" {
  value     = vastdata_user_key.s3key1.access_key
  sensitive = true
}

output "s3_secret_key_encrypted" {
  value     = vastdata_user_key.s3key1.encrypted_secret_key
  sensitive = true
}
