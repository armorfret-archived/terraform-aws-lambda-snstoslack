terraform {
  required_providers {
    aws = {
      version = "3.4.0"
    }
  }
}

module "publish-user" {
  source         = "armorfret/s3-publish/aws"
  version        = "0.2.4"
  logging_bucket = var.logging_bucket
  publish_bucket = var.config_bucket
}

data "aws_iam_policy_document" "lambda_perms" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.config_bucket}/*",
      "arn:aws:s3:::${var.config_bucket}",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_sns_topic" "this" {
  name = var.config_bucket
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}

module "lambda" {
  source  = "armorfret/lambda/aws"
  version = "0.0.4"

  source_bucket  = var.lambda_bucket
  source_version = var.lambda_version
  function_name  = "snstoslack-${var.config_bucket}"

  environment_variables = {
    S3_BUCKET = var.config_bucket
    S3_KEY    = "config.yaml"
  }

  access_policy_document = data.aws_iam_policy_document.lambda_perms.json

  source_types = ["sns"]
  source_arns  = [aws_sns_topic.this.arn]
}

