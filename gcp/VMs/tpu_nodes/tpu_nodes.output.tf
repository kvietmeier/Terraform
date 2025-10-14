###===================================================================================###
# Outputs for available TPU runtimes and accelerator types
###===================================================================================###

/* 
# --- TPU Runtime Versions ---
output "available_tpu_runtime_versions" {
  description = "List of TPU runtime versions available in the selected zone"
  value = [
    for v in data.google_tpu_v2_runtime_versions.available.runtime_versions :
    v.version
  ]
}

# --- TPU Accelerator Types ---
output "available_tpu_accelerator_types" {
  description = "List of TPU accelerator types available in the selected zone"
  value = [
    for t in data.google_tpu_v2_accelerator_types.available.accelerator_types :
    t.type
  ]
}

# --- Optional Pretty Print ---
output "available_tpu_runtime_versions_pretty" {
  value = join("\n", [
    for v in data.google_tpu_v2_runtime_versions.available.runtime_versions :
    v.version
  ])
}

output "available_tpu_accelerator_types_pretty" {
  value = join("\n", [
    for t in data.google_tpu_v2_accelerator_types.available.accelerator_types :
    t.type
  ])
}
*/