module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "standard"
  }
}

module "eventhub" {
  source  = "cloudnationhq/evh/azure"
  version = "~> 4.0"


  namespace = {
    name                = module.naming.eventhub_namespace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    authorization_rules = {
      diagnostics = {
        listen = true
        send   = true
        manage = false
      }
    }

    eventhubs = {
      diagnostics = {
        partition_count   = 2
        message_retention = 1
      }
    }
  }
}

module "diagnostics" {
  source  = "cloudnationhq/mds/azure"
  version = "~> 2.0"

  diagnostic_settings = {
    eventhub_authorization_rule_id = module.eventhub.namespace_authorization_rules.diagnostics.id
    eventhub_name                  = module.eventhub.eventhubs.diagnostics.name

    settings = {
      keyvault = {
        target_resource_id = module.kv.vault.id
      }
    }
  }
}
