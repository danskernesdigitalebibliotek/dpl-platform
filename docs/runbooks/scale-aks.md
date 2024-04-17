# Scaling AKS

## When to use

When the cluster is over or underprovisioned and needs to be scaled.

## Prerequisites

* A running [dplsh](using-dplsh.md) launched from `./infrastructure` with
  `DPLPLAT_ENV` set to the platform environment name.

## References

* For general information about AKS and node-pools <https://learn.microsoft.com/en-us/azure/aks/use-multiple-node-pools>

## Procedure

There are multiple approaches to scaling AKS. We run with the auto-scaler enabled
which means that in most cases the thing you want to do is to adjust the max or
minimum configuration for the autoscaler.

* [Adjusting the autoscaler](#adjusting-the-autoscaler)

### Adjusting the autoscaler

Edit the infrastructure configuration for your environment. Eg for `dplplat01`
edit `infrastructure/environments/dplplat01/infrastructure/main.tf`.

Adjust the `..._count_min` / `..._count_min` corresponding to the node-pool you
want to grow/shrink.

Then run `infra:provision` to have terraform effect the change.

```shell
task infra:provision
```
