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
of the [DPL shell](../../../dpl-platform/tools/dplsh), and that you have a
properly authenticated azure CLI (`az`). This is require to bootstrap the access
to the various credentials the tools requires to function.

First `cd` to the `infrastructure`, then launch the shell.

The shell will contact Azure to retrive a storage account key Terraform needs to
access its state, and export it and other require credentials via a number of
environment variables. See `.dplsh.profile` for details.

While inside the shell, use `DPLPLAT_ENV=<name> task` to run the pieces of
automation you need or export `DPLPLAT_ENV` to simplify repeated executions.

Running `task` without any arguments will yield a list of targets:

```shell
cd infrastructure
dplsh
# or if you do not have dplsh on path
../tools/dplsh/dplsh.sh

# From with the shell
dplsh:~/host_mount$ DPLPLAT_ENV=dplplat01 task <target>

# Or if you expect to run task multiple times
dplsh:~/host_mount$ export DPLPLAT_ENV=dplplat01
dplsh:~/host_mount$ task <target>
```

Any applied changes is persisted into the environments remote state-file. This
means that you should be careful to coordinate when you commit changes to
`.tf` files to git with when they are applied with your team. The recommended
approach is to commit and merge any applied changes as quickly as possible.

# Installing a platform environment from scratch
The following describes how to set up a whole new platform environment to host
 platform sites.

The easiest way to set up a new environment is to create a new `environments/<name>`
directory and copy the contents of an existing environment replacing any
references to the previous environment with a new value corresponding to the new
environment.

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

# Provision a lagoon core into the cluster. You can skip the steps about
# email setup as we currently do not support sending emails.
task lagoon:provision:core

# Configure the CLI (the cli itself has already been installed)
# First you must access the lagoon UI and add the ssh-key you wish to use for the
# admin-account. Consult the official guide for the steps.
# Then:
task lagoon:cli:config

# You can now add additional users, this step is currently skipped.

# Install Harbor.
# Skip the step that asks you to update the lagoon-core release with the
# credentials for Harbor as we've already set that ahead of time.
task lagoon:provision:harbor

# Install a Lagoon Remote into the cluster
task lagoon:provision:remote

# Register the cluster administered by the Remote with Lagoon Core
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
#     - be named after the platform environment (eg. dplplat01-terraform)
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

## Add a new site to the platform
The following describes how to add a new site to the platform. In order to do
this you need to
* Create a github "environment" repository that contains the description of
  what should be deployed to the environment.
* Create a Lagoon project and connect it to the repository

After these steps has been completed, you can continue to deploying to the
site.

### Sites configuration (sites.yaml)
The definition of which sites the platform supports is captured in a `sites.yaml`
file, this file can be found in the root of the platform environments IoC folder
eg `infrastructure/environments/dplplat01/sites.yaml` for the platform environment
 `dplplat01`.

 The file contains a single map, where the configuration of the individual sites
 is contained under the property `sites.<unique site key>`, eg.

 ```yaml
sites:
  # Site objects are indexed by a unique key that must be a valid lagoon, and
  # github project name. That is, alphanumeric and dashes.
  core-test1:
    name: "Core test 1"
    description: "Core test site no. 1"
    # Fully configured sites will have a deployment key generated by Lagoon.
    deploy_key: "ssh-ed25519 <key here>"
  bib-rb:
    name: "Rødovre Bibliotek"
    description: "Webmaster environment for Rødovre Bibliotek"
 ```

### Create the environment repository for the site
Create an entry for the site in `sites.yaml` (see previous section) where you
specify an unique key, name and description. You will add the deployment key in
a later step.

For now, run `task env_repos:provision` to create the repository.

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
# TODO
# This is a work in progress as we refine the automation around project creation
# and deletion. There are a lot of manuel steps as it stands right now.

# From within dplsh DPLPLAT_ENV exported with a value for the current platform
# environment:

# If your ssh-key is passphrase-projected we'll need to setup an ssh-agent
# instance:
$ eval $(ssh-agent); ssh-add

# 1. Authenticate against lagoon
$ task lagoon:cli:config

# 2. Add a project
# PROJECT_NAME=<project name>  GIT_URL=<url> task lagoon:project:add
$ PROJECT_NAME=core-test1  GIT_URL=git@github.com:danishpubliclibraries/env-core-test1.git task lagoon:project:add

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
### Deploy a dpl-cms release to a core test site
Prerequisites:
* a shell with a user that is authorized to interact with the github environment-repository in question over ssh.

*Notice*: We currently do not have a flow for using Git inside dplsh. As the deployment to a site relies on Git you will have to run the following outside dplsh.

The following describes how to do a simple deployment. Consult the [dpladm](dpladm) directory for more examples of how to use the various features of the deployment tool.
```sh
# Deploy
SITE=<sitename> RELEASE_TAG=<dpl-cms-source-tag> task site:deploy
```

### Removing a site from the platform
To remove a site you need to
* Remove the project from Lagoon
* Delete the projects namespace from kubernetes.
* Delete the environment repository
* The platform environment name and github organization (Consult the [platform environment documentation](https://github.com/danskernesdigitalebibliotek/dpl-platform/wiki/Platform-Environments))

Prerequisites:
* An user with administrative access to the environment repository
* A lagoon account with your ssh-key associated
* A "machine" name for the site, the can contain a-z, 0-9 and dashes.
* An properly authenticated azure CLI (`az`) that has administrative access to
  the cluster running the lagoon installation

```sh
# Launch dplsh.
$ cd infrastructure
$ dplsh

# You are assumed to be inside dplsh from now on.

# Set an environment,
# export DPLPLAT_ENV=<platform environment name>
# eg.
$ export DPLPLAT_ENV=dplplat01

# Setup access to ssh-keys so that the lagoon cli can authenticate.
$ eval $(ssh-agent); ssh-add

# Authenticate against lagoon
$ task lagoon:cli:config

# Add a project
# lagoon delete project --project <site machine-name>
$ lagoon delete project  --project core-test1

# Authenticate against kubernetes
$ task cluster:auth

# List the namespaces
$ kubectl get ns

# Identify all the project namespace with the syntax <sitename>-<branchname>
# eg "core-test1-main" for the main branch for the "core-test1" site.
# delete each namespace
# kubectl delete ns <namespace>
# eg.
kubectl delete ns core-test1-main
```

Finally access the github organization that hosts the environment repository and
delete the environment-repository named * `env-<site_name>`,
 eg "env-core-test1".
