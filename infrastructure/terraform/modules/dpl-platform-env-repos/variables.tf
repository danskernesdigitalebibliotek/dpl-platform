variable "organisation_name" {
  description = "Name of the organisation we should create repositories under."
  type        = string
}

variable "webhook_url" {
  description = "The lagoon webhook url to configure registries to push to. Eg. https://webhookhandler.lagoon.example.com"
  type        = string
}

locals {
  # Read in the list of sites from the root module, eg.
  # infrastructure/environments/dplplat01/sites.yaml
  sites_config = yamldecode(file("${path.root}/../sites.yaml"))

  # The "sites" entry in the file is an object with a key pr site we need to
  # create a repository for. The key is required to be a valid github project
  # name.
  sites = local.sites_config.sites
}

