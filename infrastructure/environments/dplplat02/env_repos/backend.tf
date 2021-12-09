terraform {
  backend "azurerm" {
    storage_account_name = "stdpltfstatealpha001"
    container_name       = "state"
    key                  = "dplplat02_github.tfstate"
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {
  # Personal Access Token is assumed to have been made available via the
  # GITHUB_TOKEN environment variable and thus is not configured here.

  # The provider needs to be configured with the organization that we're
  # creating repositories in.
  owner = "danishpubliclibraries"
}

