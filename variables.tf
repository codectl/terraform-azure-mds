variable "diagnostic_settings" {
  description = "Diagnostic settings configuration"
  type = object({
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    partner_solution_id            = optional(string)
    log_analytics_destination_type = optional(string)
    settings = optional(map(object({
      target_resource_id             = string
      log_analytics_workspace_id     = optional(string)
      use_existing_workspace         = optional(bool, false)
      name                           = optional(string)
      resource_group_name            = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
      partner_solution_id            = optional(string)
      log_analytics_destination_type = optional(string)
      logs = optional(object({
        enable_all         = optional(bool, true)
        categories         = optional(set(string), [])
        category_groups    = optional(set(string), [])
        exclude_categories = optional(set(string), [])
      }), {})
      metrics = optional(object({
        enable_all         = optional(bool, true)
        categories         = optional(set(string), [])
        exclude_categories = optional(set(string), [])
      }), {})
      diag_name = optional(string)
    })), {})
  })
}

variable "destinations" {
  description = "Global diagnostic destinations (new or existing)"
  type = object({
    log_analytics_workspace_id = optional(string)
    use_existing_workspace     = optional(bool, false)
    name                       = optional(string)
    resource_group_name        = optional(string)
  })
  default  = {}
  nullable = false
}
