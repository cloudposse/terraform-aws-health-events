provider "aws" {
  region = var.region
}

module "event_rules_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "0.7.0"

  list_config_local_base_path = path.module
  list_config_paths           = var.event_rules_config_paths

  context = module.this.context
}

module "health_events" {
  source = "../.."

  subscribers = var.subscribers
  event_rules = module.event_rules_yaml_config.list_configs

  context = module.this.context
}
