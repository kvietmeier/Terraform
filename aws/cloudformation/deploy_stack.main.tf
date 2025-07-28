/* 

 Source:  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack
 
 template_body vs template_url:
  Use template_body = file("path") if your JSON/CFN is local.
  Use template_url = "https://s3.amazonaws.com/.../voccf.json" if it’s hosted on S3.

 IAM Capabilities:
  CAPABILITY_NAMED_IAM is needed because the stack defines IAM roles and policies.
  CAPABILITY_AUTO_EXPAND is often used if macros are in play (not mandatory here but safe to include).

 Parameter Formatting:
  Comma-separated values must be quoted as a single string.
  The CFN stack handles splitting values internally.

 File Format:
  Make sure the CFN template is in JSON or YAML.
  If your file is called voccf.txt, rename it to voccf.json.

*/

provider "aws" {
  region = "us-west-2"  # Replace with your region
}

resource "aws_cloudformation_stack" "vast_mcvms" {
  name         = "vast-mcvms-stack"
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  template_body = file("${path.module}/voccf.json") # Ensure voccf.json is in your repo

  # or 

  # Replace with the actual public or signed S3 URL of your template
  #template_url = "https://s3.amazonaws.com/your-bucket-name/templates/voccf.json"

  parameters = {
    EnableCallHome    = "false"                           # Set to "true" if call home is desired
    KeyName           = "your-ec2-keypair"                # Must exist in the region
    SecurityGroupIds  = "sg-0123456789abcdef0"            # Comma-separated string of SG IDs
    DBSubnetsGroup    = "subnet-aaaa1111,subnet-bbbb2222" # Must be in the same VPC
    BucketName        = "your-existing-s3-bucket"         # Must exist in the region
    AdditionalTags    = "Environment,Dev,Owner,Karl"      # Optional: Up to 7 key-value pairs
    ExtraParams       = ""                                # Leave blank unless directed by VAST
    DbSecurityGroupId = "sg-0abcdef1234567890"            # Optional: leave blank to auto-create
  }

  tags = {
    Name          = "vast-mcvms"
    Project       = "VoC"
    Owner         = "Karl"
    Environment   = "Dev"
    VoC_component = "mcvms"
  }
}
