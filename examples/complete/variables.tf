variable "region" {
  type        = string
  description = "AWS region"
}

variable "event_rules_config_paths" {
  type        = list(string)
  description = "List of paths to Event Rule configurations."
}

variable "subscribers" {
  type        = map(any)
  description = "Map of SNS Topic subscribers."
}
