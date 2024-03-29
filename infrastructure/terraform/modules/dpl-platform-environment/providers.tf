terraform {
  required_providers {
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = ">=1.3.1"
    }

    azuread = {
      version = ">=2.6.0"
    }

    azurerm = {
      version = ">=3.33.0"
    }

    random = {
      version = ">=3.0.0"
    }
  }
}
