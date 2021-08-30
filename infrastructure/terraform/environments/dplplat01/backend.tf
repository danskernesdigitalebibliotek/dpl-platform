terraform {
  backend "azurerm" {
    storage_account_name = "stdpltfstatealpha001"
    container_name       = "state"
    key                  = "dplplat01.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8ac8a259-5bb3-4799-bd1e-455145b12550"
}
