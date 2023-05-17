data "aws_caller_identity" "this" {}

module "sns_kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"
  count   = local.create_kms_key ? 1 : 0

  description         = "KMS key for the AWS Personal Health Dashboard Events SNS topic"
  enable_key_rotation = true
  alias               = "alias/health-events-sns"
  policy              = local.create_kms_key ? data.aws_iam_policy_document.sns_kms_key_policy[0].json : ""

  context = module.this.context
}

data "aws_iam_policy_document" "sns_kms_key_policy" {
  count = local.create_kms_key ? 1 : 0

  policy_id = "EventBridgeEncryptUsingKey"

  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.20.1"

  subscribers       = var.subscribers
  sqs_dlq_enabled   = false
  kms_master_key_id = local.create_kms_key ? module.sns_kms_key[0].alias_name : var.kms_master_key_id

  allowed_aws_services_for_sns_published = ["events.amazonaws.com"]

  context = module.this.context
}

resource "aws_cloudwatch_event_target" "sns" {
  for_each = aws_cloudwatch_event_rule.health_events
  rule     = each.value.name
  arn      = module.sns_topic.sns_topic.arn
}
