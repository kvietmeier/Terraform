###===================================================================================###
# Outputs for available TPU runtimes and accelerator types
###===================================================================================###

###===================================================================================###
# TPU Information Outputs
# Compatible with Google Beta provider 7.x+
###===================================================================================###

/* 

# Raw data dump for TPU runtime versions
output "tpu_runtime_versions_raw" {
  description = "Full raw data object for TPU runtime versions (for debugging)."
  value       = data.google_tpu_v2_runtime_versions.available
}

# Raw data dump for TPU accelerator types
output "tpu_accelerator_types_raw" {
  description = "Full raw data object for TPU accelerator types (for debugging)."
  value       = data.google_tpu_v2_accelerator_types.available
}

*/