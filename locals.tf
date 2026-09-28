locals {
  workspaces = {
    for key, ws in merge({ for k, s in var.diagnostic_settings.settings : "ex_${k}" => s }, { global = var.destinations }) :
    key => { name = ws.name, resource_group_name = ws.resource_group_name }
    if ws.use_existing_workspace && ws.name != null && ws.resource_group_name != null
  }

  defaults = {
    log_analytics_workspace_id     = try(data.azurerm_log_analytics_workspace.this["global"].id, var.destinations.log_analytics_workspace_id)
    storage_account_id             = var.diagnostic_settings.storage_account_id
    eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_authorization_rule_id
    eventhub_name                  = var.diagnostic_settings.eventhub_name
    partner_solution_id            = var.diagnostic_settings.partner_solution_id
    log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type
  }

  settings = {
    for key, setting in var.diagnostic_settings.settings : key => merge(
      setting,
      { for k, v in local.defaults : k => setting[k] != null ? setting[k] : v },
      try({ log_analytics_workspace_id = data.azurerm_log_analytics_workspace.this["ex_${key}"].id }, {})
    )
  }
}
