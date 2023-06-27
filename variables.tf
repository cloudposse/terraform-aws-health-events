variable "event_rules" {
  type = list(object({
    name        = string
    description = string
    event_rule_pattern = object({
      detail = object({
        service             = string
        event_type_category = string
        event_type_codes    = list(string)
      })
    })
  }))

  description = <<-DOC
    A list of Event Rules to use when creating EventBridge Rules for the AWS Personal Health Service.

    name:
      The base name of the Event Rule (final name will be used in tandem with context attributes)
    description:
      The description to use for the Event Rule
    event_rule_pattern:
      The Event Rule Pattern to use when creating the Event Rule.
      For more information, see: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html
  DOC
}

variable "kms_master_key_id" {
  type        = string
  description = <<EOT
  The ID or alias of the customer master key (CMK) to use for encrypting the Amazon SNS topic.
  The CMK must have its resource-based policy allow the service `cloudwatch.amazonaws.com` to perform `kms:Decrypt` and `kms:GenerateDataKey` on it.
  If this variable is not supplied, a CMK with the sufficient resource-based policy will be created and used when configuring encryption for
  the SNS topic.
  EOT
  default     = null
}

variable "subscribers" {
  type = map(object({
    protocol = string
    # The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially supported, see below) (email is an option but is unsupported, see below).
    endpoint = string
    # The endpoint to send data to, the contents will vary with the protocol. (see below for more information)
    endpoint_auto_confirms = bool
    # Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty (default is false)
    raw_message_delivery = bool
    # Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property) (default is false)
  }))
  description = "Required configuration for subscribers to SNS topic."
  default     = {}
}

variable "sns_topic_name" {
  type        = string
  description = "The name of sns topic"
  default     = ""
}
