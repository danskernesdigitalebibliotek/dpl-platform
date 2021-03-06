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

Sample entry (beware that this example be out of sync with the environment you
are operating, so make sure to compare it with existing entries from the
environment)

```yaml
sites:
  bib-rb:
    name: "Roskilde Bibliotek"
    description: "Roskilde Bibliotek"
    primary-domain: "www.roskildebib.dk"
    secondary-domains: ["roskildebib.dk"]
    dpl-cms-release: "1.2.3"
    << : *default-release-image-source
```

The last entry merges in a default set of properties for the source of release-
images. If the site is on the "programmer" plan, specify a custom set of
properties like so:

```yaml
sites:
  bib-rb:
    name: "Roskilde Bibliotek"
    description: "Roskilde Bibliotek"
    primary-domain: "www.roskildebib.dk"
    secondary-domains: ["roskildebib.dk"]
    dpl-cms-release: "1.2.3"
    # Github package registry used as an example here, but any registry will
    # work.
    releaseImageRepository: ghcr.io/some-github-org
    releaseImageName: some-image-name
```

Be aware that the referenced images needs to be publicly available as Lagoon
currently only authenticates against ghcr.io.

Then continue to provision the a Github repository for the site.

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

# Then export a github personal access-token with pull access.
# We could pass this to task directly like the rest of the variables but we
# opt for the export to keep the execution of task a bit shorter.
$ export VARIABLE_VALUE=<github pat>

# Then get the project id by listing your projects
$ lagoon list projects

# Finally, add the credentials
$ VARIABLE_TYPE_ID=<project id> \
  VARIABLE_TYPE=PROJECT \
  VARIABLE_SCOPE=CONTAINER_REGISTRY \
  VARIABLE_NAME=GITHUB_REGISTRY_CREDENTIALS \
  task lagoon:set:environment-variable

# If you get a "Invalid Auth Token" your token has probably expired, generated a
# new with "lagoon login" and try again.

# 5. Trigger a deployment manually, this will fail as the repository is empty
#    but will serve to prepare Lagoon for future deployments.
# lagoon deploy branch -p <project-name> -b <branch>
$ lagoon deploy branch -p core-test1 -b main
```

If you want to deploy a release to the site, continue to
[Deploying a release](deploy-a-release.md).
