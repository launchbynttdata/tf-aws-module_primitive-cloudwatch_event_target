// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length
  region                  = join("", split("-", data.aws_region.current.name))
  use_azure_region_abbr   = var.use_azure_region_abbr
}

data "aws_iam_policy_document" "logs_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.logs_kms.json

  tags = merge(var.tags, { Name = module.resource_names["kms_key"].standard })
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/events/${module.resource_names["log_group"].standard}"
  retention_in_days = 1
  kms_key_id        = aws_kms_key.logs.arn

  tags = var.tags
}

data "aws_iam_policy_document" "example_log_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.example.arn}:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.example.arn}:*:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.example.arn]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "example" {
  policy_document = data.aws_iam_policy_document.example_log_policy.json
  policy_name     = module.resource_names["log_group"].standard
}

resource "aws_cloudwatch_event_rule" "example" {
  name        = module.resource_names["event_rule"].standard
  description = "Event rule for CloudWatch Log Group target example"

  event_pattern = jsonencode({
    source      = ["test"]
    detail-type = ["TestEvent"]
  })

  tags = var.tags
}

module "event_target" {
  source = "../.."

  rule = aws_cloudwatch_event_rule.example.name
  arn  = aws_cloudwatch_log_group.example.arn

  target_id      = coalesce(var.target_id, module.resource_names["event_target"].standard)
  event_bus_name = var.event_bus_name
  role_arn       = var.role_arn
  force_destroy  = var.force_destroy

  input             = var.input
  input_path        = var.input_path
  input_transformer = var.input_transformer

  appsync_target            = var.appsync_target
  batch_target              = var.batch_target
  dead_letter_config        = var.dead_letter_config
  ecs_target                = var.ecs_target
  http_target               = var.http_target
  kinesis_target            = var.kinesis_target
  redshift_target           = var.redshift_target
  retry_policy              = var.retry_policy
  run_command_targets       = var.run_command_targets
  sqs_target                = var.sqs_target
  sagemaker_pipeline_target = var.sagemaker_pipeline_target
}
