terraform {
  required_version = ">= 1.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

# shared vars
variable "location" {}
variable "resource_group_name" {}
variable "vnets" {}

# local vars
variable "virtual_network_name" {} # Update in terraform.tfvars on local folder to match with the one under vmseries deployment

resource "azurerm_resource_group" "palo" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "core" {
  name     = var.vnets[var.virtual_network_name].resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  address_space       = var.vnets[var.virtual_network_name].address_space
}

resource "azurerm_subnet" "this" {
  for_each = var.vnets[var.virtual_network_name].subnets

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}
