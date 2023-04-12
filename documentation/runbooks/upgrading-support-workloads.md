# Upgrading Support Workloads

## When to use

When you want to upgrade support workloads in the cluster. This includes.

* Cert manager
* Ingress Nginx
* ...

TODO, complete

## Prerequisites

TODO

## References

TODO

## Procedure

* Identify the version you want to bump in the `environment/configuration` directory
  eg for dplplat01 [infrastructure/environments/dplplat01/configuration/versions.env](../../infrastructure/environments/dplplat01/configuration/versions.env)

* Consult any relevant changelog to determine if the upgrade will require any
  extra work beside the upgrade itself.

* Identify the relevant task in the main [Taskfile](../../infrastructure/Taskfile.yml)
  for upgrading the workload. For example, for cert-manager, the task is called
  `support:provision:cert-manager`.

* Run the task with `DIFF=1`, eg `DIFF=1 task support:provision:cert-manager`.

TODO: update the support upgrade scripts to include a y/N prompt for whether to
proceed with the upgrade if the user has not specified DIFF=1.

* If the diff looks good, run the task without `DIFF=1`, eg `task support:provision:cert-manager`.

* Then proceeded to perform the verification test for the relevant workload. See
  the following section for known verification tests.

## Verification tests

### Cert Manager

TODO
