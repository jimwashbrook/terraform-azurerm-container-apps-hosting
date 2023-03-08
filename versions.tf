terraform {
  required_version = ">= 1.3.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.41.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
