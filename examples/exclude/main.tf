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

module "law" {
  source  = "cloudnationhq/law/azure"
  version = "~> 4.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 5.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.0.0.0/16"]
  }
}

module "diagnostics" {
  source  = "cloudnationhq/mds/azure"
  version = "~> 2.0"

  destinations = {
    log_analytics_workspace_id = module.law.workspace.id
  }

  diagnostic_settings = {
    settings = {
      storage = {
        target_resource_id = module.storage.account.id

        logs = {
          enable_all         = true
          exclude_categories = ["StorageDelete"]
        }

        metrics = {
          enable_all = true
        }
      }

      vnet = {
        target_resource_id = module.network.vnet.id

        logs = {
          enable_all = true
        }

        metrics = {
          enable_all         = true
          exclude_categories = ["AllMetrics"]
        }
      }
    }
  }
}
