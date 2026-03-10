module "env_repos" {
  source            = "../../../terraform/modules/dpl-platform-env-repos/"
  organisation_name = "dplplatinfra01"
  webhook_url       = "https://webhookhandler.lagoon.dplplat02.dpl.reload.dk"
}

output "site_repositories" {
  value = module.env_repos.site_repositories
}
