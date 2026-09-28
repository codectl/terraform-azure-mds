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

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.0.0.0/16"]

    subnets = {
      frontend = {
        address_prefixes = ["10.0.1.0/24"]

        network_security_group = {
          rules = {
            allow_https = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
              description                = "Allow HTTPS"
            }
          }
        }
      }

      backend = {
        address_prefixes = ["10.0.2.0/24"]

        network_security_group = {
          rules = {
            allow_sql = {
              priority                   = 200
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "1433"
              source_address_prefix      = "10.0.1.0/24"
              destination_address_prefix = "*"
              description                = "Allow SQL from frontend subnet"
            }
          }
        }
      }
    }
  }
}

module "diagnostics" {
  source  = "cloudnationhq/mds/azure"
  version = "~> 2.0"

  destinations = {
    log_analytics_workspace_id = module.law.workspace.id
  }

  diagnostic_settings = {
    settings = merge({
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
      }, {
      for nsg_key, nsg in module.network.network_security_group :
      "nsg_${nsg_key}" => {
        target_resource_id = nsg.id

        logs = {
          enable_all = true
        }

        metrics = {
          enable_all = false
        }
      }
    })
  }
}
