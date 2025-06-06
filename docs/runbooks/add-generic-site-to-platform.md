# Add a generic site to the platform

## When to use

When you want to add a "generic" site to the platform. By Generic we mean a site
stored in a repository that that is [Prepared for Lagoon](https://docs.lagoon.sh/drupal/step-by-step-getting-drupal-ready-to-run-on-lagoon/)
and contains a `.lagoon.yml` at its root.

The current main example of such as site is [dpl-cms](https://github.com/danskernesdigitalebibliotek/dpl-cms)
which is used to develop the shared DPL install profile.

## Prerequisites

* An authenticated `az` cli. The logged in user must have full administrative
  permissions to the platforms azure infrastructure.
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* A Lagoon account on the Lagoon core with your ssh-key associated (created through
  the Lagoon UI, on the Settings page)
* The git-url for the sites environment repository (you don't need to create this
  repository - it will be created by the task below - but the URL must match the
  Github repository that will be created)
* A personal access-token that is allowed to pull images from the image-registry
  that hosts our images.
* The platform environment name (Consult the [platform environment documentation](https://github.com/danskernesdigitalebibliotek/dpl-platform/wiki/Platform-Environments))

## Procedure

The following describes a semi-automated version of "Add a Project" in
[the official documentation](https://docs.lagoon.sh/installing-lagoon/add-project/).

```sh
# From within dplsh:

# Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# If your ssh-key is passphrase-projected we'll need to setup an ssh-agent
# instance:
$ eval $(ssh-agent); ssh-add

# 1. Add a project
# PROJECT_NAME=<project name>  GIT_URL=<url> task lagoon:project:add
$ PROJECT_NAME=dpl-cms GIT_URL=git@github.com:danskernesdigitalebibliotek/dpl-cms.git\
  task lagoon:project:add

# 1.b You can also run lagoon add project manually, consult the documentation linked
#     in the beginning of this section for details.

# 2. Deployment key
# The project is added, and a deployment key is printed. Copy it and configure
# the GitHub repository. See the official documentation for examples.
$ PROJECT_NAME=dpl-cms task lagoon:project:deploykey

# 3. Webhook
# Configure Github to post events to Lagoons webhook url.
# The webhook url for the environment will be
#  https://webhookhandler.lagoon.<environment>.dpl.reload.dk
# eg for the environment dplplat01
#  https://webhookhandler.lagoon.dplplat01.dpl.reload.dk
#
# Referer to the official documentation linked above for an example on how to
# set up webhooks in github.

# 4. Trigger a deployment manually, this will fail as the repository is empty
#    but will serve to prepare Lagoon for future deployments.
# lagoon deploy branch -p <project-name> -b <branch>
$ lagoon deploy branch -p dpl-cms -b main
```
