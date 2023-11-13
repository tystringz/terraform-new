
# --- GENERAL --- #
location            = "East US"
resource_group_name = "rg-cnct-palo-01"
# name_prefix           = "" # <- TO BE DEFINED, prefix for all resources to be created if desired.
create_resource_group = false
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = false



# --- VNET PART --- #
vnets = {
  "vnet-cnct-eastus-01" = {
    create_virtual_network = false
    resource_group_name    = "rg-cnct-core-01"
    address_space          = ["10.199.200.0/24"]
    network_security_groups = {
      "management" = {
        rules = {
          vmseries_mgmt_allow_panorama = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["192.168.40.7"] # Panorama IP
            source_port_range          = "*"
            destination_address_prefix = "10.199.200.96/27"
            destination_port_ranges    = ["22", "443"] # <- TO BE DEFINED, ports need to be adjusted
          }
          vmseries_mgmt_allow_inbound = {
            priority                   = 200
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["134.238.135.137", "134.238.135.14", "134.238.91.229", "134.238.91.231"] # <- TO BE DEFINED Put your own public IP address here - to be adjusted by the customer
            source_port_range          = "*"
            destination_address_prefix = "10.199.200.96/27"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
      "private" = {}
      "public"  = {}
    }
    route_tables = {
      "udr-management" = {
        routes = {
          trust_blackhole = {
            address_prefix = "10.199.200.64/27"
            next_hop_type  = "None"
          }
          untrust_blackhole = {
            address_prefix = "10.199.200.32/27"
            next_hop_type  = "None"
          }
        }
      }
      "udr-untrust" = {
        routes = {
          mgmt_blackhole = {
            address_prefix = "10.199.200.96/27"
            next_hop_type  = "None"
          }
          trust_blackhole = {
            address_prefix = "10.199.200.64/27"
            next_hop_type  = "None"
          }
        }
      }
      "udr-trust" = {
        routes = {
          default = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.199.200.94" # @TODO: do we need this route?
          }
          mgmt_blackhole = {
            address_prefix = "10.199.200.96/27"
            next_hop_type  = "None"
          }
          untrust_blackhole = {
            address_prefix = "10.199.200.32/27"
            next_hop_type  = "None"
          }
        }
      }
    }
    create_subnets = false
    subnets = {
      "snet-cnct-fw-ext-eastus" = {
        address_prefixes       = ["10.199.200.32/27"]
        network_security_group = "public"
        route_table            = "udr-untrust"
      }
      "snet-cnct-fw-int-eastus" = {
        address_prefixes = ["10.199.200.64/27"]
        # network_security_group = ""
        route_table = "udr-trust"
      }
      "snet-cnct-fw-mgmt-eastus" = {
        address_prefixes       = ["10.199.200.96/27"]
        network_security_group = "management"
        route_table            = "udr-management"
      }
    }
  }
}



# --- LOAD BALANCING PART --- #
load_balancers = {
  "lb-public" = {
    vnet_name                   = "vnet-cnct-eastus-01"
    network_security_group_name = "public"
    network_security_allow_source_ips = [
      #  "x.x.x.x", # <- TO BE DEFINED Put your own public IP address here - to be adjusted by the customer
      "134.238.135.137", # <- REMOVE when deploying to customer
      "134.238.135.14",  # <- REMOVE when deploying to customer
      "134.238.91.229",  # <- REMOVE when deploying to customer
      "134.238.91.231"   # <- REMOVE when deploying to customer
    ]
    # avzones = ["1", "2", "3"]   # we do-not have availability zones in the project.

    frontend_ips = {
      "palo-lb-app1-pip" = {
        create_public_ip = true
        rules = {
          "balanceHttp" = {
            protocol = "Tcp"
            port     = 80
          }
          "balanceHttps" = {
            protocol = "Tcp"
            port     = 443
          }
        }
      }
    }
  }
  "lb-private" = {
    frontend_ips = {
      "ha-ports" = {
        vnet_name          = "vnet-cnct-eastus-01"
        subnet_name        = "snet-cnct-fw-int-eastus"
        private_ip_address = "10.199.200.94" # Internal LB IP
        rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}



# --- VMSERIES PART --- #
availability_set = {
  "vmseries" = {}
}

vmseries_version  = "10.1.6"
vmseries_vm_size  = "Standard_DS3_v2"
vmseries_sku      = "byol"
vmseries_password = "123QWEasd"
vmseries = {
  "vmseries-1" = {
    availability_set_name = "vmseries"
    # app_insights_settings = {}
    vnet_name = "vnet-cnct-eastus-01"
    interfaces = {
      mgmt = {
        subnet_name        = "snet-cnct-fw-mgmt-eastus"
        create_pip         = true
        private_ip_address = "10.199.200.100"
      }
      trust = {
        subnet_name          = "snet-cnct-fw-int-eastus"
        private_ip_address   = "10.199.200.68"
        backend_pool_lb_name = "lb-private"
      }
      untrust = {
        subnet_name          = "snet-cnct-fw-ext-eastus"
        backend_pool_lb_name = "lb-public"
        create_pip           = true
        private_ip_address   = "10.199.200.36"
      }
    }
  }
  "vmseries-2" = {
    availability_set_name = "vmseries"
    # app_insights_settings = {}
    vnet_name = "vnet-cnct-eastus-01"
    interfaces = {
      mgmt = {
        subnet_name        = "snet-cnct-fw-mgmt-eastus"
        create_pip         = true
        private_ip_address = "10.199.200.101"
      }
      trust = {
        subnet_name          = "snet-cnct-fw-int-eastus"
        private_ip_address   = "10.199.200.69"
        backend_pool_lb_name = "lb-private"
      }
      untrust = {
        subnet_name          = "snet-cnct-fw-ext-eastus"
        backend_pool_lb_name = "lb-public"
        create_pip           = true
        private_ip_address   = "10.199.200.37"
      }
    }
  }
}

# Bootstrap storage account settings
storage_account_name = "vhpantfstorage" # <- TO BE DEFINED, this should be unique across Azure
storage_share_name   = "bootstrapshare" # <- TO BE DEFINED

files = {                                    # <- TO BE DEFINED, find sample files under files/ folder and update
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}
