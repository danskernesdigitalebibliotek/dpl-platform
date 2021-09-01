terraform {
  required_providers {
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = ">=0.6.0"
    }

    azuread = {
      version = ">=2.0.0"
    }

    azurerm = {
      version = ">=2.0.0"
    }

    random = {
      version = ">=3.0.0"
    }

  }
}
