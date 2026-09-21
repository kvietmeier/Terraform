###===================================================================================###
#
#  File:  bind.outputs.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

output "bind_private_ip" {
  description = "Private IP of the BIND forwarder — point clients here"
  value       = aws_instance.bind.private_ip
}

output "bind_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.bind.id
}

output "security_group_ids" {
  description = "Existing security groups attached to the forwarder"
  value       = var.security_group_ids
}

output "instance_tags" {
  description = "Tags applied to the instance"
  value       = local.instance_tags
}

output "vast_zones" {
  description = "Zones forwarded to VAST"
  value       = var.vast_zones
}

output "vast_dns_ips" {
  description = "VAST DNS target IPs"
  value       = var.vast_dns_ips
}

output "ssh_command" {
  description = "SSH into the forwarder"
  value = format(
    "ssh -i %s %s@%s",
    var.ssh_private_key_path,
    var.ssh_user,
    aws_instance.bind.private_ip
  )
}

output "client_resolv_snippet" {
  description = "systemd-resolved drop-in for test clients (selective VAST domain routing)"
  value       = <<-EOT
    # /etc/systemd/resolved.conf.d/vast-forwarder.conf
    [Resolve]
    DNS=${aws_instance.bind.private_ip}
    Domains=${join(" ", [for z in var.vast_zones : "~${z}"])}
  EOT
}

output "verify_commands" {
  description = "Quick dig checks from the BIND VM or a client"
  value = join("\n", concat(
    [for z in var.vast_zones : "dig @${aws_instance.bind.private_ip} something.${z}"],
    ["dig @${aws_instance.bind.private_ip} google.com"]
  ))
}
