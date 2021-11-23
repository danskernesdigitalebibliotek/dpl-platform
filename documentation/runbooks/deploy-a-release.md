# Deploy a dpl-cms release to a site

## When to use

When you wish to roll out a release of [DPL-CMS](https://github.com/danskernesdigitalebibliotek/dpl-cms)
to a single site.

If you want to deploy to more than one site, simply repeat the procedure for each
site.

## Prerequisites

* A [dplsh session](using-dplsh.md) with DPLPLAT_ENV exported and ssh-agent configured.
* a shell with a user that is authorized to interact with the [environment
  repositories](../platform-environments.md) in the github organisation used for
   the environment over ssh.

## Procedure

```sh
# 1. Make any changes to the sites entry sites.yml you need.
# 2. (optional) diff the deployment
DIFF=1 SITE=<sitename> task site:sync
# 3. Synchronize the site, triggering a deployment if the current state differs
#    from the intended state in sites.yaml
```
