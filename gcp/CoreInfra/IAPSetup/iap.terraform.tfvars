###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  Allowed to be in the repo, but sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

# Instances variable is currently not used in IAM assignments.
# It is included here for future use cases that may require
# instance-level role assignments or configurations.
instances = [
  {name = "client01",    zone = "us-east1-c"},
  {name = "client02",    zone = "us-east1-c"},
  {name = "client03",    zone = "us-east1-c"},
  {name = "client04",    zone = "us-east1-c"},
  {name = "client05",    zone = "us-east1-c"},
  {name = "client06",    zone = "us-east1-c"},
  {name = "client07",    zone = "us-east1-c"},
  {name = "client08",    zone = "us-east1-c"},
  {name = "client09",    zone = "us-east1-c"},
  {name = "client10",    zone = "us-east1-c"},
  {name = "client11",    zone = "us-east1-c"},
  {name = "w22server01", zone = "us-west2-b"},
  {name = "devops01",    zone = "us-west2-a"}
]
