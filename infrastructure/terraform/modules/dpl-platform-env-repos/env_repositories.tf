# Create a repository pr. site.
resource "github_repository" "site" {
  for_each = local.sites

  name        = format("%senv-%s", var.prefix, each.key)
  description = "${each.value.name}. ${each.value.description}"
  visibility  = "private"
  auto_init   = true
  # TODO - this should be set to true as we approach production.
  archive_on_destroy = false
}

resource "github_branch" "moduletest_branch" {
  for_each = { for key, val in local.sites : key => val if try(val.plan, "standard") == "webmaster" }

  branch     = "moduletest"
  repository = github_repository.site[each.key].name
}

# Grant the default teams their respective permissions on the repository.
resource "github_team_repository" "site_team_default_read" {
  for_each = local.sites

  team_id    = github_team.default_read.id
  repository = github_repository.site[each.key].name
  permission = "pull"
}

resource "github_team_repository" "site_team_default_admin" {
  for_each = local.sites

  team_id    = github_team.default_admin.id
  repository = github_repository.site[each.key].name
  permission = "admin"
}

resource "github_team_repository" "site_team_default_write" {
  for_each = local.sites

  team_id    = github_team.default_write.id
  repository = github_repository.site[each.key].name
  permission = "push"
}
