data "azurerm_log_analytics_workspace" "this" {
  for_each = local.workspaces

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_monitor_diagnostic_categories" "this" {
  for_each = var.diagnostic_settings.settings

  resource_id = each.value.target_resource_id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = local.settings

  name = coalesce(
    each.value.diag_name, each.key
  )

  target_resource_id             = each.value.target_resource_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id
  log_analytics_destination_type = each.value.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = each.value.logs.enable_all ? setsubtract(
      data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types,
      each.value.logs.exclude_categories
    ) : each.value.logs.categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.logs.category_groups

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metrics.enable_all ? setsubtract(
      data.azurerm_monitor_diagnostic_categories.this[each.key].metrics,
      each.value.metrics.exclude_categories
    ) : each.value.metrics.categories

    content {
      category = enabled_metric.value
    }
  }
}
