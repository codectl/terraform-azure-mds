output "diagnostic_settings" {
  description = "All diagnostic settings"
  value       = azurerm_monitor_diagnostic_setting.this
}

output "diagnostic_categories" {
  description = "Available diagnostic categories per resource"
  value = {
    for key, data in data.azurerm_monitor_diagnostic_categories.this : key => {
      log_category_types  = data.log_category_types
      log_category_groups = data.log_category_groups
      metrics             = data.metrics
    }
  }
}

output "enabled_logs" {
  description = "Enabled log categories per diagnostic setting"
  value = {
    for key, setting in var.diagnostic_settings.settings : key => {
      categories = try(setting.logs.enable_all, true) ? setsubtract(
        toset(data.azurerm_monitor_diagnostic_categories.this[key].log_category_types),
        toset(try(setting.logs.exclude_categories, []))
      ) : toset(try(setting.logs.categories, []))
      category_groups = toset(try(setting.logs.category_groups, []))
    }
  }
}

output "enabled_metrics" {
  description = "Enabled metric categories per diagnostic setting"
  value = {
    for key, setting in var.diagnostic_settings.settings : key => try(setting.metrics.enable_all, true) ? setsubtract(
      toset(data.azurerm_monitor_diagnostic_categories.this[key].metrics),
      toset(try(setting.metrics.exclude_categories, []))
    ) : toset(try(setting.metrics.categories, []))
  }
}
