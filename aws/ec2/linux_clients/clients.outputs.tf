###===================================================================================###
#
#  File:  clients.outputs.tf
#  Created By: Karl Vietmeier
#
#  Connection helpers for the identical client pool
#
###===================================================================================###

output "vm_names" {
  value       = local.vm_names
  description = "Generated VM names (vm_base_name + 01, 02, ...)"
}

output "vm_private_ips" {
  value       = { for name, vm in aws_instance.vm_instance : name => vm.private_ip }
  description = "Map of VM name to private IP"
}

output "vm_ids" {
  value       = { for name, vm in aws_instance.vm_instance : name => vm.id }
  description = "Map of VM name to instance ID"
}

output "ssh_commands" {
  description = "Formatted SSH commands (private IP; use VPN/bastion as needed)"
  value = {
    for name, vm in aws_instance.vm_instance :
    name => format(
      "ssh -i %s %s@%s",
      var.ssh_private_key_path,
      var.ssh_user,
      vm.private_ip
    )
  }
}

output "serial_console_urls" {
  description = "AWS EC2 Serial Console browser links"
  value = {
    for name, vm in aws_instance.vm_instance :
    name => format(
      "https://%s.console.aws.amazon.com/ec2/home?region=%s#SerialConsole:instanceId=%s",
      var.region,
      var.region,
      vm.id
    )
  }
}

output "connection_info" {
  description = "Copy/paste block: SSH + serial console per VM"
  value = join("\n\n", [
    for name, vm in aws_instance.vm_instance : <<-EOT
      === ${name} (${vm.id}) ===
      SSH:    ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${vm.private_ip}
      Serial: https://${var.region}.console.aws.amazon.com/ec2/home?region=${var.region}#SerialConsole:instanceId=${vm.id}
    EOT
  ])
}
