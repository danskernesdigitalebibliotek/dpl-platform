# Register a webhook pr repository that will let Lagoon react on pushes and
# pull-requests.
resource "github_repository_webhook" "lagoon_deploy" {
  for_each = local.sites

  repository = github_repository.site[each.key].name

  configuration {
    url          = var.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push", "pull_request"]
}

# Add a deployment key to the site repo if specified.
resource "github_repository_deploy_key" "site_deployment_key" {
  for_each = {
    for k, v in local.sites :
    # Only include map entries that has a deployment key.
    k => v if length(try(v.deploy_key, "")) > 0
  }

  # Setup the Lagoon deployment key if available.
  title      = "Lagoon Deploy Key"
  repository = github_repository.site[each.key].name
  key        = each.value.deploy_key
  read_only  = "true"
}
