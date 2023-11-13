# Upgrading Lagoon

## When to use

When there is a need to upgrade Lagoon to a new patch or minor version.

## References

* Official [Updating](https://docs.lagoon.sh/installing-lagoon/update-lagoon/) documentation.
* Lagoon [Releases](https://github.com/uselagoon/lagoon/releases)

## Prerequisites

* A running [dplsh](using-dplsh.md) launched from `./infrastructure` with
  `DPLPLAT_ENV` set to the platform environment name.
* Knowledge about the version of Lagoon you want to upgrade to.
  * You can extract version (= chart version) and appVersion (= lagoon release
    version) for the lagoon-remote / lagoon-core charts via the following commands
    (replace lagoon-core for lagoon-remote if necessary).

Lagoon-core:

```shell
curl -s https://uselagoon.github.io/lagoon-charts/index.yaml \
  | yq '.entries.lagoon-core[] | [.name, .appVersion, .version, .created] | @tsv'
```

Lagoon-remote:

```shell
curl -s https://uselagoon.github.io/lagoon-charts/index.yaml \
  | yq '.entries.lagoon-remote[] | [.name, .appVersion, .version, .created] | @tsv'
```

* Knowledge of any breaking changes or necessary actions that may affect the
  platform when upgrading. See chart release notes for *all* intermediate chart
  releases.

## Procedure

1. Upgrade Lagoon core
    1. Backup the API and Keycloak dbs as described in [the official documentation](https://docs.lagoon.sh/installing-lagoon/update-lagoon/#database-backups)
    2. Bump the chart version `VERSION_LAGOON_CORE` in
       `infrastructure/environments/<env>/lagoon/lagoon-versions.env`
    3. Perform a helm diff
        * `DIFF=1 task lagoon:provision:core`
    4. Perform the actual upgrade
        * `task lagoon:provision:core`
2. Upgrade Lagoon remote
    1. Bump the chart version `VERSION_LAGOON_REMOTE` in
      `infrastructure/environments/<env>/lagoon/lagoon-versions.env`
    2. Perform a helm diff
        * `DIFF=1 task lagoon:provision:remote`
    3. Perform the actual upgrade
        * `task lagoon:provision:remote`
    4. Take note in the output from Helm of any CRD updates that *may* be required
