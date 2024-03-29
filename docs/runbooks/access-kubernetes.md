# Access Kubernetes

## When to use

When you need to gain `kubectl` access to a platform-environments Kubernetes cluster.

## Prerequisites

* An authenticated `az` cli (from the host). This likely means `az login
  --tenant TENANT_ID`, where the tenant id is that of  "DPL Platform". See Azure
  Portal > Tenant Properties. The logged in user must have permissions to list
  cluster credentials.
* `docker` cli which is [authenticated against the GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).
  The access token used must have the `read:packages` scope.

## Procedure

1. cd to `dpl-platform/infrastructure`
2. Launch the [dpl shell](../../tools/dplsh): `dplsh`
3. Set the platform envionment, eg. for "dplplat01": `export DPLPLAT_ENV=dplplat01`
4. Authenticate: `task cluster:auth`

Your dplsh session should now be authenticated against the cluster.
