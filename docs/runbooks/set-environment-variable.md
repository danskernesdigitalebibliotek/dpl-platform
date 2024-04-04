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
* A Lagoon account on the Lagoon core with your ssh-key associated (created
  through the Lagoon UI, on the Settings page)

## Procedure

```sh
# From within a dplsh session authorized to use your ssh keys:

# 1. Authenticate against the cluster and lagoon
$ task cluster:auth
$ task lagoon:cli:config

# 2. Refresh your Lagoon token.
$ lagoon login

# 3a. For project-level variables, use the following command, which creates
#     the variable if it does not yet exist, or updates it otherwise:
$ task lagoon:ensure:environment-variable \
  PROJECT_NAME=<project name> \
  VARIABLE_SCOPE=RUNTIME \
  VARIABLE_NAME=<your variable name> \
  VARIABLE_VALUE=<your variable value>

# 3b. Or, to similarly ensure the value of an environment-level variable:
$ task lagoon:ensure:environment-variable \
  PROJECT_NAME=<project name> \
  ENVIRONMENT_NAME=<environment name> \
  VARIABLE_SCOPE=RUNTIME \
  VARIABLE_NAME=<your variable name> \
  VARIABLE_VALUE=<your variable value>

# If you get a "Invalid Auth Token" your token has probably expired, generated a
# new with "lagoon login" and try again.
```
