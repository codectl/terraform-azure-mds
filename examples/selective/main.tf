module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "law" {
  source  = "codectl/law/azure"
  version = "~> 1.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    blob_properties = {
      containers = {
        logs = {}
        data = {}
      }
    }
  }
}

module "kv" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "standard"
  }
}

module "diagnostics" {
  source  = "codectl/mds/azure"
  version = "~> 1.0"

  destinations = {
    log_analytics_workspace_id = module.law.workspace.id
  }

  diagnostic_settings = {
    settings = {
      storage = {
        target_resource_id = module.storage.account.id

        metrics = {
          enable_all = false
          categories = ["Transaction"]
        }
      }

      storage_blob_service = {
        target_resource_id = "${module.storage.account.id}/blobServices/default"

        logs = {
          enable_all = false
          categories = ["StorageWrite"]
        }

        metrics = {
          enable_all = false
          categories = ["Transaction"]
        }
      }

      keyvault = {
        target_resource_id = module.kv.vault.id

        logs = {
          enable_all = false
          categories = ["AuditEvent"]
        }
      }
    }
  }
}
