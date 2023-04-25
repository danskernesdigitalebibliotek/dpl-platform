# Set an environment variable for a site

## When to use

When you wish to set an environment variable on a site. The variable can be
available for either all sites in the project, or for a specific site in the
project.

The variables are safe for holding secrets, and as such can be used both for
"normal" configuration values, and secrets such as api-keys.

The variabel will be available to all containers in the environment can can be
picked up and parsed eg. in Drupals `settings.php`.

## Prerequisites

* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name and ssh-agent running if your ssh-keys are passphrase
  protected.
* An user that has administrative privileges on the lagoon project in question.

## Procedure

```sh
# From within a dplsh session authorized to use your ssh keys:

# 1. Authenticate against the cluster and lagoon
$ task cluster:auth
$ task lagoon:cli:config

# 2. Refresh your Lagoon token.
$ lagoon login

# 3. Then get the project id by listing your projects
$ lagoon list projects

# 4. Optionally, if you wish to set a variable for a single environment - eg a
# pull-request site, list the environments in the project
$ lagoon list environments -p <project name>

# 5. Finally, set the variable
# - Set the the type_id to the id of the project or environment depending on
#   whether you want all or a single environment to access the variable
# - Set scope to VARIABLE_TYPE or ENVIRONMENT depending on the choice above
# - set
$ VARIABLE_TYPE_ID=<project or environment id> \
  VARIABLE_TYPE=<PROJECT or ENVIRONMENT> \
  VARIABLE_SCOPE=RUNTIME \
  VARIABLE_NAME=<your variable name> \
  VARIABLE_VALUE=<your variable value> \
  task lagoon:set:environment-variable

# If you get a "Invalid Auth Token" your token has probably expired, generated a
# new with "lagoon login" and try again.
```

The variable will be available the next time the site is deployed by Lagoon.
Use [the deployment runbook](deploy-a-release.md) to trigger a deployment, use
a forced deployment if you do not have a new release to deploy.
