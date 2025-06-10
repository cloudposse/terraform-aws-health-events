locals {
  enabled        = module.this.enabled
  create_kms_key = local.enabled && var.kms_master_key_id == null
  event_rules    = { for event_rule in var.event_rules : event_rule.name => event_rule }
}

module "health_events_label" {
  for_each = local.event_rules
  source   = "cloudposse/label/null"
  version  = "0.25.0"

  attributes = [each.key]
  context    = module.this.context
}

resource "aws_cloudwatch_event_rule" "health_events" {
  for_each    = local.event_rules
  name        = module.health_events_label[each.key].id
  description = each.value.description
  tags        = module.this.tags

  event_pattern = jsonencode(
    {
      "source" : [
        "aws.health"
      ],

    }
  )
}
