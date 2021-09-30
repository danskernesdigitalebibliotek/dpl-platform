terraform {
  backend "azurerm" {
    storage_account_name = "stdpltfstatealpha001"
    container_name       = "state"
    key                  = "dplplat01.tfstate"
  }
}

terraform {
  required_providers {
    dnsimple = {
      source = "dnsimple/dnsimple"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8ac8a259-5bb3-4799-bd1e-455145b12550"
}

provider "dnsimple" {
  sandbox = false
}

provider "azuread" {
  tenant_id = "7235d751-8bbc-4ec9-97ba-f541c34cc434"
}

