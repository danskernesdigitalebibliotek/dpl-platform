# How to rollback a site

## When to use

Use this runbook when a site needs to be rolled back. A site might need a
rollback for several reasons: a bad release, a piece of
editorial work has been lost.


## Prerequisites

* A running [dplsh](using-dplsh.md) launched from `./infrastructure` with
  `DPLPLAT_ENV` set to the platform environment name.
* Knowledge of the current version running and the desired version that should
  that should be rolled back to.

## Procedure

1. In the `infrastructure/environments/dplplat01/sites.yaml` adjust the right release anchor.
