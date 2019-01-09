module "publish-user" {
  source         = "github.com/akerl/terraform-aws-s3-publish"
  logging-bucket = "${var.logging-bucket}"
  publish-bucket = "${var.config-bucket}"
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_perms" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.config-bucket}/*",
      "arn:aws:s3:::${var.config-bucket}",
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

resource "aws_sns_topic" "topic" {
  name = "${var.topic}"
}

resource "aws_sns_topic_subscription" "sub" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
}

module "lambda" {
  source = "github.com/akerl/terraform-aws-lambda"

  lambda-bucket  = "${var.lambda-bucket}"
  lambda-version = "${var.version}"
  function-name  = "sns-to-slack"

  environment-variables = {
    S3_BUCKET = "${var.config-bucket}"
    S3_KEY    = "config.yaml"
  }

  access-policy-document = "${data.aws_iam_policy_document.lambda_perms.json}"
  trust-policy-document  = "${data.aws_iam_policy_document.lambda_assume.json}"

  source-types = ["sns"]
  source-arns  = ["${aws_sns_topic.topic.arn}"]
}
