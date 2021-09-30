# Terraform

This directory contains the configuration and tooling we use to support our
use of terraform.

## The Terraform setup

The setup keeps a single terraform-state pr. environment. Each state is kept as
separate blobs in a Azure Storage Account.

![](../../../../documentation/diagrams/render-png/terraform_overview.png)

Access to the storage account is granted via a Storage Account Key which is
kept in a Azure Key Vault in the same resource-group. The key vault, storage account
and the resource-group that contains these resources are the only resources
that are not provisioned via Terraform.

### Initial setup of Terraform

The following procedure must be carried out before the first environment can be
created.

Prerequisites:

- A Azure subscription
- An authenticated azure CLI that is allowed to use create resources and grant
  access to these resources under the subscription including Key Vaults.
  The easiest way to achieve this is to grant the user the `Owner` and `Key Vault Administrator`
  roles to on subscription.

Use the `scripts/bootstrap-tf.sh` for bootstrapping. After the script has been
run successfully it outputs instructions for how to set up a terraform module
that uses the newly created storage-account for state-tracking.

As a final step you must grant any administrative users that are to use the setup
permission to read from the created key vault.

### Dnsimple

The setup uses an integration with DNSimple to set a domain name when the
environments ingress ip has been provisioned. To use this integration first
[obtain a api-key](https://support.dnsimple.com/articles/api-access-token/) for
the DNSimple account. Then use `scripts/add-dnsimple-apikey.sh` to write it to
the setups Key Vault and finally add the following section to `.dplsh.profile` (
get the subscription id and key vault name from existing export for `ARM_ACCESS_KEY`).

```shell
export DNSIMPLE_TOKEN=$(az keyvault secret show --subscription "<subscriptionid>" --name dnsimple-api-key --vault-name <key vault-name> --query value -o tsv)
export DNSIMPLE_ACCOUNT="<dnsimple-account-id>"
```

### Terraform Setups

A setup is used to manage a set of environments. We currently have a single that
manages all environments.

#### Alpha

- Name: alpha
- Resource-group: rg-tfstate-alpha
- Key Vault name: kv-dpltfstatealpha001
- Storage account: stdpltfstatealpha001

## Terraform Modules

### Environment modules
We use a root "environment" module pr. environment which in turn uses our main
platform module for provisioning.

Consult the general [environment documentation](../../../../dpl-platform-poc/infrastructure/platform-environment.md)
for descriptions on which resources you can expect to find in an environment and
how they are used.

Consult the [environment overview](environments/README.md) for an overview of
environments.

Each environment root-module uses a shared module for provisioning the actual
environment.

### DPL Platform Terraform Module

The [dpl-platform-environment](./dpl-platform-environment) Terraform module
provisions all resources that are required for a single DPL Platform Environment.

Inspect [variables.tf](./dpl-platform-environment/variables.tf) for a description of the required module-
variables.

Inspect [outputs.tf](./dpl-platform-environment/outputs.tf) for a list of outputs.

Inspect the individual module files for documentation of the resources.

The following diagram depicts (amongst other things) the provisioned resources.
Consult the [platform environment documentation](../../../../documentation/platform-environment.md) for more details on the role the various resources
plays.
![](../../../../documentation/diagrams/render-png/dpl-platform-azure.png)
