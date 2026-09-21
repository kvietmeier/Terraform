###===================================================================================###
#
#  File:  autoshutdown.main.tf
#  Created By: Karl Vietmeier
#
#  Policy: nightly (configurable) StopInstances for running EC2 with
#          AutoShutdown=true. Opt out by omitting the tag or setting false.
#          Leave AutoShutdown unset on long-running services / always-on hosts.
#
###===================================================================================###

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  fn_name = "${var.name_prefix}-autoshutdown"
  tags = merge(var.common_tags, {
    Purpose = "lab-autoshutdown"
    owned   = "solutions"
  })
}

data "archive_file" "autoshutdown" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/.build/autoshutdown.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${local.fn_name}-lambda"
  path = "/solutions/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "${local.fn_name}-ec2-stop"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "FindAndStopTagged"
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:StopInstances", "ec2:CreateTags"]
        Resource = "*"
      },
      {
        Sid      = "Logs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:${data.aws_partition.current.partition}:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      },
    ]
  })
}

resource "aws_lambda_function" "autoshutdown" {
  function_name    = local.fn_name
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.autoshutdown.output_path
  source_code_hash = data.archive_file.autoshutdown.output_base64sha256
  timeout          = 60
  memory_size      = 128

  environment {
    variables = {
      AUTO_SHUTDOWN_TAG_KEY   = var.auto_shutdown_tag_key
      AUTO_SHUTDOWN_TAG_VALUE = var.auto_shutdown_tag_value
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "autoshutdown" {
  name              = "/aws/lambda/${aws_lambda_function.autoshutdown.function_name}"
  retention_in_days = 14
  tags              = local.tags
}

resource "aws_iam_role" "scheduler" {
  name = "${local.fn_name}-scheduler"
  path = "/solutions/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "scheduler" {
  name = "${local.fn_name}-invoke"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = aws_lambda_function.autoshutdown.arn
    }]
  })
}

resource "aws_scheduler_schedule" "autoshutdown" {
  name                         = local.fn_name
  description                  = "Stop instances tagged ${var.auto_shutdown_tag_key}=${var.auto_shutdown_tag_value}"
  schedule_expression          = var.shutdown_cron
  schedule_expression_timezone = var.shutdown_timezone
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.autoshutdown.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
