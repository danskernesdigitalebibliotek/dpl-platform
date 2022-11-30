# Upgrading AKS

## When to use

When you want to upgrade Azure Kubernetes Service to a newer version.

## Prerequisites

* A running [dplsh](using-dplsh.md) launched from `./infrastructure` with
  `DPLPLAT_ENV` set to the platform environment name.
* Knowledge about the version of AKS you wish to upgrade to.
  * Consult [AKS Kubernetes Release Calendar](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar)
    for a list of the various versions and when they are End of Life

## References

* <https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster>
* <https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools#upgrade-a-node-pool>
* <https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions>

## Procedure

We use Terraform to upgrade AKS. Should you need to do a manual upgrade consult
Azures documentation on [upgrading a cluster](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster)
and on [upgrading node pools](https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools#upgrade-a-node-pool).
Be aware in both cases that the Terraform state needs to be brought into sync
via some means, so this is not a recommended approach.

### Find out which versions of kubernetes an environment can upgrade to

In order to find out which versions of kubernetes we can upgrade to, we need to
use the following command:

```bash
task cluster:get-upgrades
```

This will output a table of in which the column "Upgrades" lists the available
upgrades for the highest available minor versions.

A Kubernetes cluster can can at most be upgraded to the nearest minor version,
which means you may be in a situation where you have several versions between
you and the intended version.

Minor versions can be skipped, and AKS will accept a cluster being upgraded to
a version that does not specify a patch version. So if you for instance want
to go from `1.20.9` to `1.22.15`, you can do `1.21`, and then `1.22.15`. When
upgrading to `1.21` Azure will substitute the version for an the hightest available
patch version, e.g. `1.21.14`.

You should know know which version(s) you need to upgrade to, and can continue to
the actual upgrade.

### Ensuring the Terraform state is in sync

As we will be using Terraform to perform the upgrade we want to make sure it its
state is in sync. Execute the following task and resolve any drift:

```shell
task infra:provision
```

### Upgrade the cluster

Upgrade the control-plane:

1. Update the `control_plane_version` reference in `infrastructure/environments/<environment>/infrastructure/main.tf`
  and run `task infra:provision` to apply. You can skip patch-versions, but you
  can only do [one minor-version at the time](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli#check-for-available-aks-cluster-upgrades)

2. Monitor the upgrade as it progresses. A control-plane upgrade is usually performed
   in under 5 minutes.

Monitor via eg.

```shell
watch -n 5 kubectl version
```

Then upgrade the system, admin and application node-pools in that order one by
one.

1. Update the `pool_[name]_version` reference in
   `infrastructure/environments/<environment>/infrastructure/main.tf`.
   The same rules applies for the version as with `control_plane_version`.

2. Monitor the upgrade as it progresses. Expect the provisioning of and workload
   scheduling to a single node to take about 5-10 minutes. In particular be aware
   that the admin node-pool where harbor runs has a tendency to take a long time
   as the harbor pvcs are slow to migrate to the new node.

Monitor via eg.

```shell
watch -n 5 kubectl get nodes
```
