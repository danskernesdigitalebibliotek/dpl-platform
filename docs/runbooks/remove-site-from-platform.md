# Removing a site from the platform

## When to use

When you wish to delete a site and all its data from the platform

Prerequisites:

* The platform environment name
* An user with administrative access to the environment repository
* A lagoon account with your ssh-key associated
* The site key (its key in [sites.yaml](../architecture/platform-environment-architecture.md#sitesyaml))
* An properly authenticated azure CLI (`az`) that has administrative access to
  the cluster running the lagoon installation

## Procedure

The procedure consists of the following steps (numbers does not correspond to
the numbers in the script below).

1. Download and archive relevant backups
2. Remove the project from Lagoon
3. Delete the projects namespace from kubernetes.
4. Delete the site from [sites.yaml](../architecture/platform-environment-architecture.md#sitesyaml)
5. Delete the sites environment repository

Your first step should be to secure any backups you think might be relevant to
archive. Whether this step is necessary depends on the site. Consult the
[Retrieve and Restore backups](retrieve-restore-backups.md) runbook for the
operational steps.

You are now ready to perform the actual removal of the site.

```sh
# Launch dplsh.
$ cd infrastructure
$ dplsh

# You are assumed to be inside dplsh from now on.

# 1. Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# 2. Setup access to ssh-keys so that the lagoon cli can authenticate.
$ eval $(ssh-agent); ssh-add

# 3. Authenticate against lagoon
$ task lagoon:cli:config

# 4. Delete the project from Lagoon
# lagoon delete project --project <site machine-name>
$ lagoon delete project  --project core-test1

# 5. Authenticate against kubernetes
$ task cluster:auth

# 6. List the namespaces
# Identify all the project namespace with the syntax <sitename>-<branchname>
# eg "core-test1-main" for the main branch for the "core-test1" site.
$ kubectl get ns

# 7. Delete each site namespace
# kubectl delete ns <namespace>
# eg.
$ kubectl delete ns core-test1-main

# 8. Edit sites.yaml, remove the the entry for the site
$ vi environments/${DPLPLAT_ENV}/sites.yaml
# Then have Terraform delete the sites repository.
$ task env_repos:provision
```
