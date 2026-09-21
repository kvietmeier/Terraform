###===================================================================================###
#
#  File:  bind.network.tf
#  Created By: Karl Vietmeier
#
#  Security group: clients (VPC) → UDP/TCP 53; SSH; egress to VAST + cloud resolver
#
###===================================================================================###

locals {
  query_cidrs = distinct(concat([var.vpc_cidr], var.additional_query_cidrs))
  ssh_cidr    = var.ssh_cidr != "" ? var.ssh_cidr : var.vpc_cidr
}

resource "aws_security_group" "bind" {
  name_prefix = "${var.instance_name}-"
  description = "BIND VAST conditional forwarder — DNS from VPC, SSH"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.instance_name}-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

# Inbound DNS from clients
resource "aws_vpc_security_group_ingress_rule" "dns_udp" {
  for_each = toset(local.query_cidrs)

  security_group_id = aws_security_group.bind.id
  description       = "DNS UDP from ${each.value}"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "dns_tcp" {
  for_each = toset(local.query_cidrs)

  security_group_id = aws_security_group.bind.id
  description       = "DNS TCP from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.bind.id
  description       = "SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = local.ssh_cidr
}

# Outbound DNS to VAST VIP(s)
resource "aws_vpc_security_group_egress_rule" "vast_dns_udp" {
  for_each = toset(var.vast_dns_ips)

  security_group_id = aws_security_group.bind.id
  description       = "DNS UDP to VAST ${each.value}"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${each.value}/32"
}

resource "aws_vpc_security_group_egress_rule" "vast_dns_tcp" {
  for_each = toset(var.vast_dns_ips)

  security_group_id = aws_security_group.bind.id
  description       = "DNS TCP to VAST ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${each.value}/32"
}

# Outbound DNS to AWS/GCP VPC resolver (link-local)
resource "aws_vpc_security_group_egress_rule" "cloud_resolver_udp" {
  security_group_id = aws_security_group.bind.id
  description       = "DNS UDP to cloud VPC resolver"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${var.cloud_resolver}/32"
}

resource "aws_vpc_security_group_egress_rule" "cloud_resolver_tcp" {
  security_group_id = aws_security_group.bind.id
  description       = "DNS TCP to cloud VPC resolver"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "${var.cloud_resolver}/32"
}

# Package installs / apt / chrony
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.bind.id
  description       = "HTTPS for apt / updates"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.bind.id
  description       = "HTTP for apt"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
