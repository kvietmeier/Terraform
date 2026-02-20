###===================================================================================###
#  Terraform Configuration File
#
#  Description : <Brief description of what this file does>
#  Author      : Karl Vietmeier
#
#  License     : Apache 2.0
#
###===================================================================================###

# Setup cloud-init
data "cloudinit_config" "system_setup" {
  gzip          = false
  base64_encode = true # OCI requires user_data to be base64 encoded

  part {
    content_type = "text/cloud-config"
    content      = local.cloudinit_config
    filename     = "conf.yaml"
  }
}

resource "oci_core_instance" "vm_instance" {
  for_each            = toset(local.vm_names)
  display_name        = each.value
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  shape               = var.shape

  # OCI Flex shapes allow you to define exact CPU/RAM
  dynamic "shape_config" {
    for_each = length(regexall("Flex", var.shape)) > 0 ? [1] : []
    content {
      ocpus         = var.shape_config.ocpus
      memory_in_gbs = var.shape_config.memory_in_gbs
    }
  }

  source_details {
    source_type             = "image"
    source_id               = var.os_image_id
    boot_volume_size_in_gbs = var.bootdisk_size
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${each.value}-vnic"
    assign_public_ip = true
    
    # Logic matches your GCP cidrhost() calculation
    private_ip = cidrhost(
      data.oci_core_subnet.selected_subnet.cidr_block,
      var.ip_start_offset + index(local.vm_names, each.value)
    )
  }

  metadata = {
    ssh_authorized_keys = local.ssh_key_content
    user_data           = data.cloudinit_config.system_setup.rendered
  }

  # Note: OCI usually handles cloud-init natively on most images.
  # The 'startup-script' bash loop from GCP isn't typically needed 
  # but can be added via the cloud-init yaml.
}

output "vm_private_ips" {
  value       = [for vm in oci_core_instance.vm_instance : vm.private_ip]
  description = "List of private IP addresses of the OCI instances"
}