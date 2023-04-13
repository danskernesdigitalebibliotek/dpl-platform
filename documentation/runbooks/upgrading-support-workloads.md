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

## General Procedure

* Identify the version you want to bump in the `environment/configuration` directory
  eg for dplplat01 [infrastructure/environments/dplplat01/configuration/versions.env](../../infrastructure/environments/dplplat01/configuration/versions.env).
  You can find the latest version of the support workload in the [Version status](https://docs.google.com/spreadsheets/d/15xLv-zhIL0g_gQaUfsslYVzAclrG-T5gkjII8mbRHoU/edit#gid=0)
  sheet which itself is updated via the procedure described in the
  [Update Upgrade status](update-upgrade-status.md) runbook.

* Consult any relevant changelog to determine if the upgrade will require any
  extra work beside the upgrade itself. The [Specific producedures and tests](#specific-producedures-and-tests)
  sections may contain futher documentation for specific workloads.

* Identify the relevant task in the main [Taskfile](../../infrastructure/Taskfile.yml)
  for upgrading the workload. For example, for cert-manager, the task is called
  `support:provision:cert-manager`.

* Run the task with `DIFF=1`, eg `DIFF=1 task support:provision:cert-manager`.

TODO: update the support upgrade scripts to include a y/N prompt for whether to
proceed with the upgrade if the user has not specified DIFF=1.

* If the diff looks good, run the task without `DIFF=1`, eg `task support:provision:cert-manager`.

* Then proceeded to perform the verification test for the relevant workload. See
  the following section for known verification tests.

## Specific producedures and tests

### Cert Manager

#### Upgrade cert-manager

Commands

```bash
# Diff
DIFF=1 task support:provision:cert-manager

# Upgrade
task support:provision:cert-manager
```

#### Verify cert-manager upgrade

Verify that cert-manager itself and webhook pods are all running and healthy.

```bash
task support:verify:cert-manager
```

### Grafana

#### Upgrade grafana

Charts and app releases has wildly different versions, so you should always look
at the diff between both the chart and app version.

The general upgrade procedure will give you the chart version, access the
following link to get the release note for the chart. Remember to insert your
version:

<https://github.com/grafana/helm-charts/releases/tag/grafana-6.52.9>

The note will most likely be empty. Now diff the chart version with the current
version, again replacing the version with the relevant for your releases.

<https://github.com/grafana/helm-charts/compare/grafana-6.43.3...grafana-6.52.9>

As the repository contains a lot of charts, you will need to do a bit of
digging. Look for at least `charts/grafana/Chart.yaml` which can tell you the
app version.

With the app-version in hand, you can now look at the release notes for [the
grafana app](https://github.com/grafana/grafana/blob/main/CHANGELOG.md)
itself.

Diff command

```bash
DIFF=1 task support:provision:grafana
```

Upgrade command

```bash
task support:provision:grafana
```

#### Verify grafana upgrade

Verify that the Grafana pods are all running and healthy.

```bash
kubectl get pods --namespace grafana
```

Access the Grafana UI and see if you can log in. If you do not have a user
but have access to read secrets in the `grafana` namespace, you can retrive the
admin password with the following command:

```bash
# Password for admin
UI_NAME=grafana task ui-password

# Hostname for grafana
kubectl -n grafana get -o jsonpath="{.spec.rules[0].host}" ingress grafana ; echo
```
