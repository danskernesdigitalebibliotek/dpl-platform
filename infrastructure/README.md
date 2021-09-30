# DPL Platform Infrastructure
This directory contains the Infrastructure as Code and scripts that are used
for maintaining the infrastructure-component that each platform environment
consists of.

## Directory layout
* [environments/](environments): contains a directory for each platform environment.
* [terraform](terraform): Our Terraform setup and tooling
* [task/](task): Configuration and scripts used by our Taskfile-based automation
  The scripts included in this directory _can_ be run by hand in an emergency
  but te recommended way to invoke these via task.
* [Taskfile.yml](Taskfile.yml): The [task](https://taskfile.dev) configuration. Invoke `task`
  to get a list of targets.

### Environments
The `environments` directory contains a subdirectory for each platform
environment, and each directory has two subdirectories:
* `environments/<name>/infrastructure`: contains the terraform files needed to
   provision the basic infrastructure components that the platform requires.
* `environments/<name>/configuration`: contains the various configurations the
  applications that are installed on top of the infrastructure requires.

## Day to day use
Prerequisites:
* An properly authenticated azure CLI (`az`). See the section on initial
  Terraform setup for more details on the requirements

To provision/configure a given environment we use the [DPL shell](../../../dpl-platform/tools/dplsh)
which comes with all the tools we need. While it is possible to run the
commands described below outside of the shell, it is not supported.

First `cd` to the `infrastructure/terraform`, then launch the shell.

The shell will now launch, and authenticate against Azure.

While inside the shell, use `DPLPLAT_ENV=<name> task` to run the pieces of
automation you need.

Running `task` without any arguments will yield a list of targets.

```shell
$ cd infrastructure/terraform
$ dplsh
dplsh:~/host_mount$ DPLPLAT_ENV=dplplat01 task ...

# Eg.
dplsh:~/host_mount$ DPLPLAT_ENV=dplplat01 task infra:provision
```

Any applied changes is persisted into the environments remote state-file. This
means that you should be careful to coordinate when you commit changes to
`.tf` files to git with when they are applied. For dev/test environments it is
generally acceptable to `apply` and then commit when everything is applied
correctly. For test/production environments a more rigorous process with a
review of plans may be advisable.

## Setting up a new environment

The easiest way to set up a new environment is to create a new `environments/<name>`
directory and copy the contents of an existing environment replacing any
references to the previous environment with a new value corresponding to the new
environment.

If this is the very first environment, remember to first initialize the Terraform-
setup, see the [terraform README.md](terraform/README.md).

### Provisioning infrastructure
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
### Installing and configuring Lagoon
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

You can now proceed to adding projects.

### Adding a project to Lagoon.
See "Add a Project" in [the official documentation](https://docs.lagoon.sh/lagoon/using-lagoon-advanced/installing-lagoon-into-existing-kubernetes-cluster#add-a-project).
