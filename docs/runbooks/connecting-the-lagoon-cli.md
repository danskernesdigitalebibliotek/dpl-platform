# Connecting the Lagoon CLI

## When to use

When you want to use the Lagoon API via the CLI. You can connect from the DPL
Shell, or from a local installation of the CLI.

Using the DPL Shell requires administrative privileges to the infrastructure while
a local CLI may connect using only the ssh-key associated to a Lagoon user.

This runbook documents both cases, as well as how an administrator can extract the
basic connection details a standard user needs to connect to the Lagoon installation.

## Prerequisites

* Your ssh-key associated with a lagoon user. This has to be done via the Lagoon
  UI by either you for your personal account, or by an administrator who has
  access to edit your Lagoon account.
* For local installations of the cli:
  * The [Lagoon CLI installed locally](https://docs.lagoon.sh/installing-lagoon/lagoon-cli/)
  * Connectivity details for the [Lagoon environment](../platform-environments.md)
* For administrative access to extract connection details or use the lagoon cli
  from within the dpl shell:
  * A valid [dplsh](using-dplsh.md) setup to extract the connectivity details

## Procedure

### Obtain the connection details for the environment

You can skip this step and go to [Configure your local lagoon cli](#configure-your-local-lagoon-cli))
if your environment is already in [Current Platform environments](../platform-environments.md)
and you just want to have a local lagoon cli working.

If it is missing, go through the steps below and update the document if you have
access, or ask someone who has.

```shell
# Launch dplsh.
$ cd infrastructure
$ dplsh

# 1. Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# 2. Authenticate against AKS, needed by infrastructure and Lagoon tasks
$ task cluster:auth

# 3. Generate the Lagoon CLI configuration and authenticate
# The Lagoon CLI is authenticated via ssh-keys. DPLSH will mount your .ssh
# folder from your homedir, but if your keys are passphrase protected, we need
# to unlock them.
$ eval $(ssh-agent); ssh-add
# Authorize the lagoon cli
$ task lagoon:cli:config

# List the connection details
$ lagoon config list
```

### Configure your local lagoon cli

Get the details in the angle-brackets from
[Current Platform environments](../platform-environments.md):

```shell
$ lagoon config add \
    --graphql https://<GraphQL endpoint> \
    --ui https://<Lagoon UI> \
    --hostname <SSH host> \
    --ssh-key <SSH Key Path> \
    --port <SSH port>> \
    --lagoon <Lagoon name>

# Eg.
$ lagoon config add \
    --graphql https://api.lagoon.dplplat01.dpl.reload.dk/graphql \
    --force \
    --ui https://ui.lagoon.dplplat01.dpl.reload.dk \
    --hostname 20.238.147.183 \
    --port 22 \
    --lagoon dplplat01
```

Then log in:

```shell
# Set the configuration as default.
lagoon config default --lagoon <Lagoon name>
lagoon login
lagoon whoami

# Eg.
lagoon config default --lagoon dplplat01
lagoon login
lagoon whoami
```
