# Map of site repositories on the form
# {
#   name = {
#     git_url = <git_url>
#   }
# }
output "site_repositories" {
  value = {
    for instance in github_repository.site :
    instance.name => {
      "git_url" = instance.ssh_clone_url
    }
  }
}
