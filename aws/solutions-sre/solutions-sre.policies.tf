###===================================================================================###
#
#  File:  solutions-sre.policies.tf
#  Created By: Karl Vietmeier
#
#  STATUS: NOT TESTED — generic template only. Validate before production apply.
#
#  Inline permission-set policy for a Solutions / SA / SRE lane.
#  Underlay (VPC/subnet/route/IGW/NAT/TGW) intentionally omitted — platform/IT + SCP.
#  Tune actions in this file to match your org envelope; defaults are a starting point.
#
###===================================================================================###

locals {
  s3_bucket_arns = flatten([
    for prefix in var.s3_bucket_prefixes : [
      "arn:aws:s3:::${prefix}*",
      "arn:aws:s3:::${prefix}*/*",
    ]
  ])

  dynamodb_lock_table_arns = [
    for prefix in var.dynamodb_lock_table_prefixes :
    "arn:aws:dynamodb:*:*:table/${prefix}*"
  ]
}

data "aws_iam_policy_document" "solutions_sre" {
  statement {
    sid       = "STSValidation"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  statement {
    sid = "EC2Read"
    actions = [
      "ec2:Describe*",
      "ec2:GetConsoleOutput",
      "ec2:GetManagedPrefixListEntries",
      "ec2:GetSerialConsoleAccessStatus",
      "ec2:GetSecurityGroupsForVpc",
    ]
    resources = ["*"]
  }

  # Workloads + SGs + ENI SG attach — not VPC/subnet/route/IGW/NAT/TGW
  statement {
    sid = "EC2WorkloadWrite"
    actions = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:CreateKeyPair",
      "ec2:ImportKeyPair",
      "ec2:DeleteKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:ModifySecurityGroupRules",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "ec2:ReleaseAddress",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      # Golden / reusable lab AMIs (saves re-bootstrap time & $ vs cloud-init every launch)
      "ec2:CreateImage",
      "ec2:DeregisterImage",
      "ec2:CopyImage",
      "ec2:ModifyImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeImageAttribute",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:ModifyLaunchTemplate",
      "ec2:CreateLaunchTemplateVersion",
      "ec2:CreatePlacementGroup",
      "ec2:DeletePlacementGroup",
      "ec2:CreateManagedPrefixList",
      "ec2:DeleteManagedPrefixList",
      "ec2:ModifyManagedPrefixList",
    ]
    resources = ["*"]
  }

  statement {
    sid = "InstanceConnect"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey",
      "ec2-instance-connect:SendSerialConsoleSSHPublicKey",
    ]
    resources = ["*"]
  }

  statement {
    sid = "SSMSessionOptional"
    actions = [
      "ssm:StartSession",
      "ssm:TerminateSession",
      "ssm:ResumeSession",
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
    ]
    resources = ["*"]
  }

  # After-hours lab autoshutdown (EventBridge Scheduler → Lambda → StopInstances)
  # See aws/ec2/autoshutdown/ — tag AutoShutdown=true to opt in.
  statement {
    sid = "LabAutoShutdownAutomation"
    actions = [
      "scheduler:CreateSchedule",
      "scheduler:UpdateSchedule",
      "scheduler:DeleteSchedule",
      "scheduler:GetSchedule",
      "scheduler:ListSchedules",
      "scheduler:CreateScheduleGroup",
      "scheduler:DeleteScheduleGroup",
      "scheduler:GetScheduleGroup",
      "scheduler:ListScheduleGroups",
      "scheduler:TagResource",
      "scheduler:UntagResource",
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:InvokeFunction",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:ListFunctions",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AutoScaling"
    actions = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:Describe*",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:SuspendProcesses",
      "autoscaling:ResumeProcesses",
    ]
    resources = ["*"]
  }

  statement {
    sid = "ElasticLoadBalancing"
    actions = [
      "elasticloadbalancing:Create*",
      "elasticloadbalancing:Delete*",
      "elasticloadbalancing:Modify*",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:Set*",
    ]
    resources = ["*"]
  }

  # Resolver rules only — not hosted-zone record writes
  statement {
    sid = "Route53ResolverRules"
    actions = [
      "route53resolver:CreateResolverRule",
      "route53resolver:DeleteResolverRule",
      "route53resolver:UpdateResolverRule",
      "route53resolver:AssociateResolverRule",
      "route53resolver:DisassociateResolverRule",
      "route53resolver:Get*",
      "route53resolver:List*",
      "route53resolver:TagResource",
      "route53resolver:UntagResource",
    ]
    resources = ["*"]
  }

  statement {
    sid = "Route53ReadZonesOnly"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }

  statement {
    sid = "BedrockInvoke"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ListFoundationModels",
      "bedrock:GetFoundationModel",
    ]
    resources = ["*"]
  }

  statement {
    sid = "SageMakerInvoke"
    actions = [
      "sagemaker:InvokeEndpoint",
      "sagemaker:InvokeEndpointAsync",
      "sagemaker:Describe*",
      "sagemaker:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid = "IAMManageRoles"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = [
      "arn:aws:iam::*:role/${var.iam_path_prefix}/*",
    ]
  }

  statement {
    sid = "IAMManagePolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]
    resources = [
      "arn:aws:iam::*:policy/${var.iam_path_prefix}/*",
    ]
  }

  statement {
    sid = "IAMManageInstanceProfiles"
    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile",
      "iam:ListInstanceProfiles",
    ]
    resources = [
      "arn:aws:iam::*:instance-profile/${var.iam_path_prefix}/*",
    ]
  }

  statement {
    sid = "IAMReadLists"
    actions = [
      "iam:ListRoles",
      "iam:ListGroups",
      "iam:ListUsers",
      "iam:ListPolicies",
      "iam:GetRole",
    ]
    resources = ["*"]
  }

  statement {
    sid = "SecretsManager"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents",
      "logs:TagResource",
      "logs:UntagResource",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(local.s3_bucket_arns) > 0 ? [1] : []
    content {
      sid = "S3DemoAndTfStateBuckets"
      actions = [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:PutBucketTagging",
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:GetBucketLocation",
        # Remote Terraform state hardening
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
      ]
      resources = local.s3_bucket_arns
    }
  }

  dynamic "statement" {
    for_each = length(local.dynamodb_lock_table_arns) > 0 ? [1] : []
    content {
      sid = "TfStateDynamoDBLock"
      actions = [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTable",
        "dynamodb:UpdateTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:TagResource",
        "dynamodb:UntagResource",
        "dynamodb:ListTagsOfResource",
      ]
      resources = local.dynamodb_lock_table_arns
    }
  }

  dynamic "statement" {
    for_each = length(local.dynamodb_lock_table_arns) > 0 ? [1] : []
    content {
      sid       = "TfStateDynamoDBList"
      actions   = ["dynamodb:ListTables"]
      resources = ["*"]
    }
  }

  statement {
    sid       = "S3ListAllBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid = "CloudTrailRead"
    actions = [
      "cloudtrail:DescribeTrails",
      "cloudtrail:LookupEvents",
      "cloudtrail:ListEventDataStores",
      "cloudtrail:GetTrailStatus",
    ]
    resources = ["*"]
  }
}
