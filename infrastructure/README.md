# DPL Platform Infrastructure
This directory contains the Infrastructure as Code and scripts that are used
for maintaining the infrastructure-component that each platform environment
consists of. A "platform environment" is an umbrella term for the Azure
infrastructure, the Kubernetes cluster, the Lagoon installation and the set of
GitHub environments that makes up a single DPL Platform installation.

## Directory layout
* [dpladm/](dpladm): a tool used for deploying individual sites. The tools _can_
  be run manually, but the recommended way is via the common infrastructure Taskfile.
* [environments/](environments): contains a directory for each platform environment.
* [terraform](terraform): terraform setup and tooling that is shared between
  environments.
* [task/](task): Configuration and scripts used by our Taskfile-based automation
  The scripts included in this directory _can_ be run by hand in an emergency
  but te recommended way to invoke these via task.
* [Taskfile.yml](Taskfile.yml): the common infrastructure [task](https://taskfile.dev)
  configuration. Invoke `task` to get a list of targets. Must be run from within
  an instance of [DPL shell](../../../dpl-platform/tools/dplsh) unless otherwise
  noted.

## Platform Environment configurations
The `environments` directory contains a subdirectory for each platform
environment. You generally interact with the files and directories within the
directory to configure the environment. When a modification has been made, it
is put in to effect by running the appropiate `task` :
* `configuration`: contains the various configurations the
  applications that are installed on top of the infrastructure requires. These
  are used by the `support:provision:*` tasks.
* `env_repos` contains the Terraform root-module for provisioning GitHub site-
  environment repositories. The module is run via the `env_repos:provision` task.
* `infrastructure`: contains the Terraform root-module used to provision the basic
  Azure infrastructure components that the platform requires.The module is run
  via the `infra:provision` task.
* `lagoon`: contains Kubernetes manifests and Helm values-files used for installing
  the Lagoon Core and Remote that is at the heart of a DPL Platform installation.
  THe module is run via the `lagoon:provision:*` tasks.

## Basic usage of dplsh and an environment configuration
The remaining guides in this document assumes that you work from an instance
of the [DPL shell](../../../dpl-platform/tools/dplsh). See the [DPLSH Runbook](../documentation/runbooks/using-dplsh.md) for a basic introduction to how to use dplsh.

# Installing a platform environment from scratch
The following describes how to set up a whole new platform environment to host
 platform sites.

The easiest way to set up a new environment is to create a new `environments/<name>`
directory and copy the contents of an existing environment replacing any
references to the previous environment with a new value corresponding to the new
environment. Take note of the various URLs, and make sure to update the
[Current Platform environments](../documentation/platform-environments.md)
documentation.

If this is the very first environment, remember to first initialize the Terraform-
setup, see the [terraform README.md](terraform/README.md).

## Provisioning infrastructure
When you have prepared the environment directory, launch `dplsh` and go through
the following steps to provision the infrastructure:

```shell
# We export the variable to simplify the example, you can also specify it inline.
export DPLPLAT_ENV=dplplat01

# Provision the Azure resources
task infra:provision

# Provision the support software that the Platform relies on
task support:provision
```
## Installing and configuring Lagoon
The previous step has established the raw infrastructure and the Kubernetes support
projects that Lagoon needs to function. You can proceed to follow the [official
Lagoon installation procedure](https://docs.lagoon.sh/lagoon/using-lagoon-advanced/installing-lagoon-into-existing-kubernetes-cluster).

The execution of the individual steps of the guide has been somewhat automated,
the following describes how to use the automation, make sure to follow along
in the official documentation to understand the steps and some of the
additional actions you have to take.

```shell
# The following must be carried out from within dplsh, launched as described
# in the previous step including the definition of DPLPLAT_ENV.

# 1. Provision a lagoon core into the cluster.
task lagoon:provision:core

# 2. Skip the steps in the documentation that speaks about setting up email, as
# we currently do not support sending emails.


# 3. Setup ssh-keys for the lagoonadmin user
# Access the Lagoon UI (consult the platform-environments.md for the url) and
# log in with lagoonadmin + the admin password that can be extracted from a
# Kubernetes secret:
kubectl -n lagoon-core get secret lagoon-core-keycloak -o jsonpath="{.data.KEYCLOAK_LAGOON_ADMIN_PASSWORD}" | base64 --decode

# Then go to settings and add the ssh-keys that should be able to access the
# lagoon admin user. Consider keeping this list short, and instead add
# additional users with fewer privileges laster.

# 4. If your ssh-key is passphrase-projected we'll need to setup an ssh-agent
# instance:
$ eval $(ssh-agent); ssh-add

# 5. Configure the CLI to verify that access (the cli itself has already been installed in dplsh)
task lagoon:cli:config

# You can now add additional users, this step is currently skipped.

# (6. Install Harbor.)
# This step has already been performed as a part of the installation of
# support software.

# 7. Install a Lagoon Remote into the cluster
task lagoon:provision:remote

# 8. Register the cluster administered by the Remote with Lagoon Core
# Notice that you must provide a bearer token via the USER_TOKEN environment-
# variable. The token can be found in $HOME/.lagoon.yml after a successful
# "lagoon login"
USER_TOKEN=<token> task lagoon:add:cluster:
```
The Lagoon core has now been installed, and the remote registered with it.

## Setting up a GitHub organization and repositories for a new platform environment
Prerequisites:
* An properly authenticated azure CLI (`az`). See the section on initial
  Terraform setup for more details on the requirements

First create a new administrative github user and create a new organization
with the user. The administrative user should only be used for administering
the organization via terraform and its credentials kept as safe as possible! The
accounts password can be used as a last resort for gaining access to the account
and will _not_ be stored in Key Vault. Thus, make sure to store the password
somewhere safe, eg. in a password-manager or as a physical printout.

This requires the infrastructure to have been created as we're going to store
credentials into the azure Key Vault.

```shell
# cd into the infrastructure folder and launch a shell
(host)$ cd infrastructure
(host)$ dplsh

# Remaining commands are run from within dplsh

# export the platform environment name.
# export DPLPLAT_ENV=<name>, eg
$ export DPLPLAT_ENV=dplplat01

# 1. Create a ssh keypair for the user, eg by running
# ssh-keygen -t ed25519 -C "<comment>" -f dplplatinfra01_id_ed25519
# eg.
$ ssh-keygen -t ed25519 -C "dplplatinfra@0120211014073225" -f dplplatinfra01_id_ed25519

# 2. Then access github and add the public-part of the key to the account
# 3. Add the key to keyvault under the key name "github-infra-admin-ssh-key"
# eg.
$ SECRET_KEY=github-infra-admin-ssh-key SECRET_VALUE=$(cat dplplatinfra01_id_ed25519) task infra:keyvault:secret:set

# 4. Access GitHub again, and generate a Personal Access Token for the account.
#    The token should
#     - be named after the platform environment (eg. dplplat01-terraform-timestamp)
#     - Have a fairly long expiration - do remember to renew it
#     - Have the following permissions: admin:org, delete_repo, repo
# 5. Add the access token to Key Vault under the name "github-infra-admin-pat"
# eg.
$ SECRET_KEY=github-infra-admin-pat SECRET_VALUE=githubtokengoeshere task infra:keyvault:secret:set

# Our tooling can now administer the GitHub organization
```

### Renewing the administrative GitHub Personal Access Token
The Personal Access Token we use for impersonating the administrative GitHub
user needs to be recreated periodically:

```shell
# cd into the infrastructure folder and launch a shell
(host)$ cd infrastructure
(host)$ dplsh

# Remaining commands are run from within dplsh

# export the platform environment name.
# export DPLPLAT_ENV=<name>, eg
$ export DPLPLAT_ENV=dplplat01

# 1. Access GitHub, and generate a Personal Access Token for the account.
#    The token should
#     - be named after the platform environment (eg. dplplat01-terraform)
#     - Have a fairly long expiration - do remember to renew it
#     - Have the following permissions: admin:org, delete_repo, repo
# 2. Add the access token to Key Vault under the name "github-infra-admin-pat"
# eg.
$ SECRET_KEY=github-infra-admin-pat SECRET_VALUE=githubtokengoeshere task infra:keyvault:secret:set

# 3. Delete the previous token
```

