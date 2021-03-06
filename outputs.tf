output "event_rule_names" {
  description = "The names of the created EventBridge Rules."
  value       = try([for event_rule in aws_cloudwatch_event_rule.health_events : event_rule.name], [])
}

output "event_rule_arns" {
  description = "The ARNs of the created EventBridge Rules."
  value       = try([for event_rule in aws_cloudwatch_event_rule.health_events : event_rule.arn], [])
}
