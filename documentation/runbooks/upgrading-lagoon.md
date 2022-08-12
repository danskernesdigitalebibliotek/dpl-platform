# Upgrading Lagoon

## When to use

When there is a need to upgrade Lagoon to a new patch or minor version.

## References

* Official [Updating](https://docs.lagoon.sh/installing-lagoon/update-lagoon/) documentation.
* Lagoon [Releases](https://github.com/uselagoon/lagoon/releases)

## Prerequisites

* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* Knowledge about the version of Lagoon you want to upgrade to.
  * You can extract version (= chart version) and appVersion (= lagoon release
    version) for the lagoon-remote / lagoon-core charts via the following commands
    (replace lagoon-core for lagoon-remote if necessary).

```shell
curl -s https://uselagoon.github.io/lagoon-charts/index.yaml \
  | yq '.entries.lagoon-core[] | [.name, .appVersion, .version, .created] | @tsv'
```

* Knowledge of any breaking changes or necessary actions that may affect the
  platform when upgrading. See chart release notes for *all* intermediate chart
  releases.

## Procedure

1. Upgrade Lagoon core
    1. Bump the chart version in `infrastructure/environments/<env>/lagoon/lagoon-versions.env`
    2. Perform a helm diff
       * `DIFF=1 task lagoon:provision:core`
    3. Perform the actual upgrade
       * `task lagoon:provision:core`
    4. Run database migrations
      * `task lagoon:provision:core-db-migration`
2. Upgrade Lagoon remote
    1. Bump the chart version in `infrastructure/environments/dplplat01/lagoon/lagoon-versions.env`
    2. Perform a helm diff
       * `DIFF=1 task lagoon:provision:remote`
    3. Perform the actual upgrade
       * `task lagoon:provision:remote`
