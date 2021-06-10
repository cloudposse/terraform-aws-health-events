output "event_rule_names" {
  description = "The names of the created EventBridge Rules."
  value       = module.health_events.event_rule_names
}

output "event_rule_arns" {
  description = "The ARNs of the created EventBridge Rules."
  value       = module.health_events.event_rule_arns
}
