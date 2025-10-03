###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-corevpc"
