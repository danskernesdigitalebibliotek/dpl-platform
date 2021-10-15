# Add default teams to the organization
# The teams are assigned to the repositories in env_repositories.tf.
resource "github_team" "default_admin" {
  name        = "DefaultAdmin"
  description = "Users that should be admins of environment repositories pr default"
  privacy     = "closed"
}

resource "github_team" "default_read" {
  name        = "DefaultRead"
  description = "Users that should have default read access to all environment repositories"
  privacy     = "closed"
}

resource "github_team" "default_write" {
  name        = "DefaultWrite"
  description = "Users that should have default write access to all environment repositories"
  privacy     = "closed"
}

