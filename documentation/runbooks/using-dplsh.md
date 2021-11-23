# Using the DPL Shell

The Danish Public Libraries Shell is a container-based shell used by platform-
operators for all cli operations.

## When to use

Whenever you perform any administrative actions on the platform. If you want
to know more about the shell itself? Refer to [tools/dplsh](../../tools/dplsh).

## Prerequisites

* Docker
* [jq](https://stedolan.github.io/jq/download/)
* Bash 4 or newer
* An authorized Azure `az` cli. The version should match the version found in
  `FROM mcr.microsoft.com/azure-cli:version` in the [dplsh Dockerfile](../../tools/dplsh/Dockerfile).
  You can choose to authorize the az cli from within dplsh, but your session
  will only last as long as the shell-session. The use you authorize as must
  have permission to read the Terraform state from the [Terraform setup](../../infrastructure/terraform/README.md#terraform-setups), and
  Contributor permissions on the [environments](../platform-environments.md) resource-group in order to
  provision infrastructure.
* `dplsh.sh` symlinked into your path as `dplsh`, see [Launching the Shell](../../tools/dplsh/README.md#launching-the-shell) (optional, but assumed below)

## Procedure

```sh
# Launch dplsh.
$ cd infrastructure
$ dplsh

# 1. Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# 2a. Authenticate against AKS, needed by infrastructure and Lagoon tasks
$ task cluster:auth

# 2b - if you want to use the Lagoon CLI)
# The Lagoon CLI is authenticated via ssh-keys. DPLSH will mount your .ssh
# folder from your homedir, but if your keys are passphrase protected, we need
# to unlock them.
$ eval $(ssh-agent); ssh-add
# Then authorize the lagoon cli
$ task lagoon:cli:config
```


