###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###



resource "aws_vpc" "voltdbvpc" {
  cidr_block = "172.16.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = [
    {
      Key = "Name"
      Value = "VoltDB VPC"
    }
  ]
}

resource "aws_subnet" "voltdbsubneta" {
  cidr_block = "172.16.0.0/24"
  availability_zone = "us-east-1c"
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_subnet" "voltdbsubnetb" {
  cidr_block = "172.16.1.0/24"
  availability_zone = "us-east-1e"
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_subnet" "voltdbsubnetc" {
  cidr_block = "172.16.2.0/24"
  availability_zone = "us-east-1f"
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_internet_gateway" "voltdbigw" {}

resource "aws_vpc_dhcp_options" "voltdbdhcpopts" {
  domain_name = "ec2.internal"
  domain_name_servers = [
    "AmazonProvidedDNS"
  ]
}

resource "aws_network_acl" "voltdbacl" {
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_route_table" "voltdbrt" {
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_instance" "voltdbinstance1" {
  disable_api_termination = "false"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = "true"
  // CF Property(ImageId) = var.ami
  instance_type = var.instance_type_parameter
  key_name = var.key_pair
  monitoring = "false"
  placement_group = aws_placement_group.placement_group.arn
  tags = [
    {
      Key = "Name"
      Value = join(" ", [var.cluster_name, "VoltDB Node 1"])
    }
  ]
  user_data = base64encode(join(" ", ["#!/bin/sh 
 sh -x /home/ubuntu/bin/voltwrangler.sh", "172.16.0.34,172.16.0.35,172.16.0.36", var.k_factor, var.cmd_logging, var.password, var.demo_parameter, var.instance_type_parameter, var.sph, "1", "172.16.0.34", "3", "NO", var.ssd_parameter, var.clusterid, " 2> /home/ubuntu/voltwrangler.out > /home/ubuntu/voltwrangler.lst  
"]))
  network_interface = [
    {
      delete_on_termination = "true"
      device_index = 0
      network_interface_id = aws_subnet.voltdbsubneta.id
      PrivateIpAddresses =       // CF Property(PrivateIpAddresses) = [
      //   {
      //     PrivateIpAddress = "172.16.0.34"
      //     Primary = "true"
      //   }
      // ]
      GroupSet =       // CF Property(GroupSet) = [
      //   aws_security_group.sg_volt_db_security_group.arn
      // ]
      AssociatePublicIpAddress =       // CF Property(AssociatePublicIpAddress) = "true"
    }
  ]
}

resource "aws_instance" "voltdbinstance2" {
  disable_api_termination = "false"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = "true"
  // CF Property(ImageId) = var.ami
  instance_type = var.instance_type_parameter
  key_name = var.key_pair
  monitoring = "false"
  placement_group = aws_placement_group.placement_group.arn
  tags = [
    {
      Key = "Name"
      Value = join(" ", [var.cluster_name, "VoltDB Node 2"])
    }
  ]
  user_data = base64encode(join(" ", ["#!/bin/sh 
 sh -x /home/ubuntu/bin/voltwrangler.sh", "172.16.0.34,172.16.0.35,172.16.0.36", var.k_factor, var.cmd_logging, var.password, var.demo_parameter, var.instance_type_parameter, var.sph, "2", "172.16.0.35", "3", "NO", var.ssd_parameter, var.clusterid, " 2> /home/ubuntu/voltwrangler.out > /home/ubuntu/voltwrangler.lst  
"]))
  network_interface = [
    {
      delete_on_termination = "true"
      device_index = 0
      network_interface_id = aws_subnet.voltdbsubneta.id
      PrivateIpAddresses =       // CF Property(PrivateIpAddresses) = [
      //   {
      //     PrivateIpAddress = "172.16.0.35"
      //     Primary = "true"
      //   }
      // ]
      GroupSet =       // CF Property(GroupSet) = [
      //   aws_security_group.sg_volt_db_security_group.arn
      // ]
      AssociatePublicIpAddress =       // CF Property(AssociatePublicIpAddress) = "true"
    }
  ]
}

resource "aws_instance" "voltdbinstance3" {
  disable_api_termination = "false"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = "true"
  // CF Property(ImageId) = var.ami
  instance_type = var.instance_type_parameter
  key_name = var.key_pair
  monitoring = "false"
  placement_group = aws_placement_group.placement_group.arn
  tags = [
    {
      Key = "Name"
      Value = join(" ", [var.cluster_name, "VoltDB Node 3"])
    }
  ]
  user_data = base64encode(join(" ", ["#!/bin/sh 
 sh -x /home/ubuntu/bin/voltwrangler.sh", "172.16.0.34,172.16.0.35,172.16.0.36", var.k_factor, var.cmd_logging, var.password, var.demo_parameter, var.instance_type_parameter, var.sph, "3", "172.16.0.36", "3", "NO", var.ssd_parameter, var.clusterid, " 2> /home/ubuntu/voltwrangler.out > /home/ubuntu/voltwrangler.lst  
"]))
  network_interface = [
    {
      delete_on_termination = "true"
      device_index = 0
      network_interface_id = aws_subnet.voltdbsubneta.id
      PrivateIpAddresses =       // CF Property(PrivateIpAddresses) = [
      //   {
      //     PrivateIpAddress = "172.16.0.36"
      //     Primary = "true"
      //   }
      // ]
      GroupSet =       // CF Property(GroupSet) = [
      //   aws_security_group.sg_volt_db_security_group.arn
      // ]
      AssociatePublicIpAddress =       // CF Property(AssociatePublicIpAddress) = "true"
    }
  ]
}

resource "aws_instance" "voltdblurkinginstance0" {
  disable_api_termination = "false"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = "true"
  // CF Property(ImageId) = var.ami
  instance_type = var.instance_type_parameter
  key_name = var.key_pair
  monitoring = "false"
  placement_group = aws_placement_group.placement_group.arn
  tags = [
    {
      Key = "Name"
      Value = join(" ", [var.cluster_name, "VoltDB Extra Node 0"])
    }
  ]
  user_data = base64encode(join(" ", ["#!/bin/sh 
 sh -x /home/ubuntu/bin/voltwrangler.sh", "172.16.0.34,172.16.0.35,172.16.0.36", var.k_factor, var.cmd_logging, var.password, var.demo_parameter, var.instance_type_parameter, var.sph, "0", "172.16.0.37", "3", "YES", var.ssd_parameter, var.clusterid, " 2> /home/ubuntu/voltwrangler.err > /home/ubuntu/voltwrangler.lst  
"]))
  network_interface = [
    {
      delete_on_termination = "true"
      device_index = 0
      network_interface_id = aws_subnet.voltdbsubneta.id
      PrivateIpAddresses =       // CF Property(PrivateIpAddresses) = [
      //   {
      //     PrivateIpAddress = "172.16.0.37"
      //     Primary = "true"
      //   }
      // ]
      GroupSet =       // CF Property(GroupSet) = [
      //   aws_security_group.sg_volt_db_security_group.arn
      // ]
      AssociatePublicIpAddress =       // CF Property(AssociatePublicIpAddress) = "true"
    }
  ]
}

resource "aws_security_group" "sg_volt_db_security_group" {
  description = "VoltDBSecurityGroup"
  vpc_id = aws_vpc.voltdbvpc.arn
}

resource "aws_network_acl" "voltdbacl1" {
  // CF Property(CidrBlock) = "0.0.0.0/0"
  egress = "true"
  // CF Property(Protocol) = "-1"
  // CF Property(RuleAction) = "allow"
  // CF Property(RuleNumber) = "100"
  vpc_id = aws_network_acl.voltdbacl.id
}

resource "aws_network_acl" "voltdbacl2" {
  // CF Property(CidrBlock) = "0.0.0.0/0"
  // CF Property(Protocol) = "-1"
  // CF Property(RuleAction) = "allow"
  // CF Property(RuleNumber) = "100"
  vpc_id = aws_network_acl.voltdbacl.id
}

resource "aws_network_acl_association" "voltdbsubnetacl1a" {
  network_acl_id = aws_network_acl.voltdbacl.id
  subnet_id = aws_subnet.voltdbsubneta.id
}

resource "aws_network_acl_association" "voltdbsubnetacl1b" {
  network_acl_id = aws_network_acl.voltdbacl.id
  subnet_id = aws_subnet.voltdbsubnetb.id
}

resource "aws_network_acl_association" "voltdbsubnetacl1c" {
  network_acl_id = aws_network_acl.voltdbacl.id
  subnet_id = aws_subnet.voltdbsubnetc.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "voltdbgwa" {
  vpc_id = aws_internet_gateway.voltdbigw.id
}

resource "aws_route_table_association" "voltdbsubnetrta" {
  route_table_id = aws_route_table.voltdbrt.id
  subnet_id = aws_subnet.voltdbsubneta.id
}

resource "aws_route_table_association" "voltdbsubnetrtb" {
  route_table_id = aws_route_table.voltdbrt.id
  subnet_id = aws_subnet.voltdbsubnetb.id
}

resource "aws_route_table_association" "voltdbsubnetrtc" {
  route_table_id = aws_route_table.voltdbrt.id
  subnet_id = aws_subnet.voltdbsubnetc.id
}

resource "aws_route" "voltdbsubnetroute1" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.voltdbrt.id
  gateway_id = aws_internet_gateway.voltdbigw.id
}

resource "aws_vpc_dhcp_options_association" "voltdbdhcpopts1" {
  vpc_id = aws_vpc.voltdbvpc.arn
  dhcp_options_id = aws_vpc_dhcp_options.voltdbdhcpopts.id
}

resource "aws_security_group" "voltdbingress_michael_ssh" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "22"
  // CF Property(ToPort) = "22"
  // CF Property(CidrIp) = "134.191.0.0/16"
}

resource "aws_security_group" "voltdbingress8080" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "8080"
  // CF Property(ToPort) = "8080"
  // CF Property(CidrIp) = "134.191.0.0/16"
}

resource "aws_security_group" "voltdingress7181" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "7181"
  // CF Property(ToPort) = "7181"
  vpc_id = aws_security_group.sg_volt_db_security_group.arn
}

resource "aws_security_group" "voltdbingress21211" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "21211"
  // CF Property(ToPort) = "21211"
  vpc_id = aws_security_group.sg_volt_db_security_group.arn
}

resource "aws_security_group" "voltdbingress5555" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "5555"
  // CF Property(ToPort) = "5555"
  vpc_id = aws_security_group.sg_volt_db_security_group.arn
}

resource "aws_security_group" "voltdbingress3021" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "3021"
  // CF Property(ToPort) = "3021"
  vpc_id = aws_security_group.sg_volt_db_security_group.arn
}

resource "aws_security_group" "voltdbingress3000" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "3000"
  // CF Property(ToPort) = "3000"
  // CF Property(CidrIp) = "134.191.0.0/16"
}

resource "aws_security_group" "voltdbingress910x" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "9100"
  // CF Property(ToPort) = "9102"
  // CF Property(CidrIp) = "172.16.0.0/16"
}

resource "aws_security_group" "voltdbingress9092" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "9092"
  // CF Property(ToPort) = "9092"
  // CF Property(CidrIp) = "172.16.0.0/16"
}

resource "aws_security_group" "voltdbingress21212" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "tcp"
  // CF Property(FromPort) = "21212"
  // CF Property(ToPort) = "21212"
  // CF Property(CidrIp) = "172.16.0.0/16"
}

resource "aws_security_group" "voltdbegress0000" {
  // CF Property(GroupId) = aws_security_group.sg_volt_db_security_group.arn
  // CF Property(IpProtocol) = "-1"
  // CF Property(CidrIp) = "0.0.0.0/0"
}

resource "aws_placement_group" "placement_group" {
  strategy = var.placement_group_strategy
}
