# Add a new site to the platform

## When to use

When you want to add a new core-test, editor, webmaster or programmer dpl-cms
site to the platform.

## Prerequisites

* An authenticated `az` cli. The logged in user must have full administrative
  permissions to the platforms azure infrastructure.
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.

## Procedure

The following sections describes how to

* Add the site to `sites.yaml`
* Provision Github "environment" repository
* Create a Lagoon project and connect it to the repository

After these steps has been completed, you can continue to deploying to the
site. See the [deploy-a-release.md](deploy-a-release.md) for details.

### Step 1, update sites.yaml

Create an entry for the site in `sites.yaml`.

For now specify an unique site key (its key in the map of sites), name and
description. Leave out the deployment-key, you will add it in a later step.

The continue to provision the a Github repository for the site.

### Step 2: Provision a Github repository

Run `task env_repos:provision` to create the repository.

#### Create a Lagoon project and connect the GitHub repository

Prerequisites:

* A Lagoon account on the Lagoon core with your ssh-key associated
* The git-url for the sites environment repository
* A personal access-token that is allowed to pull images from the image-registry
  that hosts our images.
* The platform environment name (Consult the [platform environment documentation](https://github.com/danskernesdigitalebibliotek/dpl-platform/wiki/Platform-Environments))

The following describes a semi-automated version of "Add a Project" in
[the official documentation](https://docs.lagoon.sh/lagoon/using-lagoon-advanced/installing-lagoon-into-existing-kubernetes-cluster#add-a-project).

```sh
# From within dplsh:

# Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# If your ssh-key is passphrase-projected we'll need to setup an ssh-agent
# instance:
$ eval $(ssh-agent); ssh-add

# 1. Authenticate against the cluster and lagoon
$ task cluster:auth
$ task lagoon:cli:config

# 2. Add a project
# PROJECT_NAME=<project name>  GIT_URL=<url> task lagoon:project:add
$ PROJECT_NAME=core-test1 GIT_URL=git@github.com:danishpubliclibraries/env-core-test1.git\
  task lagoon:project:add

# The project is added, and a deployment key is printed, use it for the next step.

# 3. Add the deployment key to sites.yaml under the key "deploy_key".
$ vi environments/${DPLPLAT_ENV}/sites.yaml
# Then update the repositories using Terraform
$ task env_repos:provision

# 4. Configure image registry credentials Lagoon should use for the project:
# Refresh your Lagoon token.
$ lagoon login

# Then get it from ~/.lagoon.yml
$ cat ~/.lagoon.yml
$ export USER_TOKEN=<token>

# Then export a github personal access-token with pull access
$ export REGISTRY_PASSWORD=<github pat>

# Then get the project id by listing your projects
$ lagoon list projects

# Finally, add the credentials
$ PROJECT_ID=<project id> task lagoon:add:registry-credentials

# If you get a "Invalid Auth Token" your token has probably expired, generated a
# new with "lagoon login" and try again.

# 5. Optional: Trigger a deployment manually (or just push to main).
# lagoon deploy branch -p <project-name> -b <branch>
$ lagoon deploy branch -p core-test1 -b main
```
