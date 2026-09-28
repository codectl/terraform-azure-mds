# Diagnostics

Terraform module to manage azure monitor diagnostic settings for any resource. It discovers available categories, supports multiple destinations, and keeps configuration map-driven and repeatable.

## Features

Works with any azure resource that supports monitor diagnostics

Dynamic category discovery; enable all, select, or exclude

Multiple sinks including, log analytics, storage, event hub, partner solution

Optional module level log analytics fallback, overridable per setting

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 5.0)

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) (data source)
- [azurerm_monitor_diagnostic_categories.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: Diagnostic settings configuration

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_destinations"></a> [destinations](#input\_destinations)

Description: Global diagnostic destinations (new or existing)

Type:

```hcl
object({
    log_analytics_workspace_id = optional(string)
    use_existing_workspace     = optional(bool, false)
    name                       = optional(string)
    resource_group_name        = optional(string)
  })
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_diagnostic_categories"></a> [diagnostic\_categories](#output\_diagnostic\_categories)

Description: Available diagnostic categories per resource

### <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings)

Description: All diagnostic settings

### <a name="output_enabled_logs"></a> [enabled\_logs](#output\_enabled\_logs)

Description: Enabled log categories per diagnostic setting

### <a name="output_enabled_metrics"></a> [enabled\_metrics](#output\_enabled\_metrics)

Description: Enabled metric categories per diagnostic setting
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)
- [Rest Api](https://learn.microsoft.com/rest/api/monitor/diagnostic-settings)
