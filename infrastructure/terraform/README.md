# DPL Platform Terraform Setup
![](../../documentation/diagrams/render-png/terraform_overview.png)


The setup keeps a single terraform-state pr. environment. Each state is kept as
separate blobs in a Azure Storage Account.

Access to the storage account is granted via a Storage Account Key which is
kept in a Azure Keyvault in the same resource-group. The keyvault, storage account
and the resource-group that contains these resources are the only resources
that are not provisioned via Terraform.


## Initial setup of Terraform
Prerequisites:

* A Azure subscription
* An authenticated azure CLI that is allowed to use the subscription - eg. has
  the `Contributor` RBAC role granted.

Use the `scripts/bootstrap-tf.sh` for bootstrapping. After the script has been
run successfully it outputs instructions for how to set up a terraform module
that uses the newly created storage-account for state-tracking.

As a final step you must grant any administrative users that are to use the setup
permission to read from the created keyvault.

## Setting up an environments
The easiest way to set up a new environment is to create a new `terraform/environments/<name>`
directory and copy a `backend.tf` file from an existing module replacing any
references to the previous environment with a new value corresponding to the new
environment.

As an alternative, or in case you don't have an existing environment module,
consult the last part of the `scripts/bootstrap-tf.sh` which outputs and example.

## Day to day use
To operate the Terraform setup for a given environment we use the DPL shell
which comes with all the tools we need. It is also possible to use a local
Terraform-client, but this approach is not supported.

First `cd` to the main terraform directory, then launch the shell, then `cd` to
the environment module folder where you can start using `terraform`.
```shell
$ cd infrastructure/terraform
$ dplsh
dplsh:~/host_mount$ cd environments/dplplat01
dplsh:~/host_mount/environments/dplplat01$ terraform init
```

Any applied changes is persisted into the environments remote state-file. This
means that you should be careful to coordinate when you commit changes to
`.tf` files to git with when they are applied. For dev/test environments it is
generally acceptable to `apply` and then commit when everything is applied
correctly. For test/production environments a more rigorous process with a
review of plans may be advisable.

# Terraform Setups

## Alpha
* Name: alpha
* Resource-group: rg-tfstate-alpha
* KeyVault name: kv-dpltfstatealpha001
* Storage account: stdpltfstatealpha001


# Environments
Consult the general [environment documentation](../../documentation/platform-environment.md)
for descriptions on which resources you can expect to find in an environment and
 how they are used.

## plat01
Initial environment used during the first implementation of the platform.

* Resource group: plat01
