# Access Kubernetes

## When to use

When you need to gain `kubectl` access to a platform-environments Kubernetes cluster.

## Prerequisites

* An authenticated `az` cli. The logged in user must have permissions to list
  cluster credentials.

## Procedure

1. cd to `dpl-platform/infrastructure`
2. Launch the [dpl shell](../../tools/dplsh): `dplsh`
3. Set the platform envionment, eg. for "dplplat01": `export DPLPLAT_ENV=dplplat01`
4. Authenticate: `task cluster:auth`

Your dplsh session should now be authenticated against the cluster.
