# Upgrading Support Workloads

## When to use

When you want to upgrade support workloads in the cluster. This includes.

- Cert-manager
- Grafana
- Harbor
- Ingress Nginx
- K8up
- Loki
- Minio
- Prometheus
- Promtail

This document contains general instructions for how to upgrade support workloads,
followed by specific instructions for each workload (linked above).

## Prerequisites

- `dplsh` instance authorized against the cluster. See [Using the DPL Shell](./using-dplsh.md).

## General Procedure

1. Identify the version you want to bump in the `environment/configuration` directory
   eg. for dplplat01 [infrastructure/environments/dplplat01/configuration/versions.env](https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/infrastructure/environments/dplplat01/configuration/versions.env).
   The file contains links to the relevant Artifact Hub pages for the individual
   projects and can often be used to determine both the latest version, but also
   details about the chart such as how a specific manifest is used.
   You can find the latest version of the support workload in the
   [Version status](https://docs.google.com/spreadsheets/d/15xLv-zhIL0g_gQaUfsslYVzAclrG-T5gkjII8mbRHoU/edit#gid=0)
   sheet which itself is updated via the procedure described in the
   [Update Upgrade status](update-upgrade-status.md) runbook.

2. Consult any relevant changelog to determine if the upgrade will require any
   extra work beside the upgrade itself.
   To determine which version to look up in the changelog, be aware of the difference
   between the [chart version](https://helm.sh/docs/topics/charts/#charts-and-versioning)
   and the [app version](https://helm.sh/docs/topics/charts/#the-apiversion-field).
   We currently track the chart versions, and not the actual version of the
   application inside the chart. In order to determine the change in `appVersion`
   between chart releases you can do a diff between releases, and keep track of the
   `appVersion` property in the charts `Chart.yaml`. Using using grafana as an example:
   <https://github.com/grafana/helm-charts/compare/grafana-6.55.1...grafana-6.56.0>.
   The exact way to do this differs from chart to chart, and is documented in the
   [Specific producedures and tests](#specific-producedures-and-tests) below.

3. Carry out any chart-specific preparations described in the charts update-procedure.
   This could be upgrading a Custom Resource Definition that the chart does not
   upgrade.

4. Identify the relevant task in the main [Taskfile](https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/infrastructure/Taskfile.yml)
   for upgrading the workload. For example, for cert-manager, the task is called
   `support:provision:cert-manager` and run the task with `DIFF=1`, eg
   `DIFF=1 task support:provision:cert-manager`.

5. If the diff looks good, run the task without `DIFF=1`, eg `task support:provision:cert-manager`.

6. Then proceeded to perform the verification test for the relevant workload. See
   the following section for known verification tests.

7. Finally, it is important to verify that Lagoon deployments still work. Some
   breaking changes will not manifest themselves until an environment is
   rebuilt, at which point it may subsequently fail. An example is the
   [disabling of user snippets in the ingress-nginx controller
   v1.9.0](https://github.com/kubernetes/ingress-nginx/pull/10393). To verify
   deployments still work, log in to the Lagoon UI and select an environment to
   redeploy.

## Specific producedures and tests

- [Cert-manager](#cert-manager)
- [Grafana](#grafana)
- [Harbor](#harbor)
- [Ingress Nginx](#ingress-nginx)
- [K8up](#k8up)
- [Loki](#loki)
- [Minio](#minio)
- [Prometheus](#prometheus)
- [Promtail](#promtail)

### Cert Manager

#### Comparing cert-manager versions

The project project versions its Helm chart together with the app itself. So,
simply use the chart version in the following checks.

Cert Manager keeps [Release notes](https://cert-manager.io/docs/release-notes/)
for the individual minor releases of the project. Consult these for every
upgrade past a minor version.

As both are versioned in the same repository, simply use the following link
for looking up the release notes for a specific patch release, replacing the
example tag with the version you wish to upgrade to.

<https://github.com/cert-manager/cert-manager/releases/tag/v1.11.2>

To compare two reversions, do the same using the following link:

<https://github.com/cert-manager/cert-manager/compare/v1.11.1...v1.11.2>

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

#### Comparing Grafana versions

Insert the chart version in the following link to see the release note.

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

#### Upgrade grafana

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

### Harbor

#### Comparing Harbor versions

Harbor has different app and chart versions.

An overview of the chart versions can be retrived
[from Github](https://github.com/goharbor/harbor-helm/tags).
the chart does not have a changelog.

Link for comparing two chart releases:
<https://github.com/goharbor/harbor-helm/compare/v1.10.1...v1.12.0>

Having identified the relevant appVersions, consult the list of
[Harbor releases](https://github.com/goharbor/harbor/releases) to see a description
of the changes included in the release in question. If this approach fails you
can also use the diff-command described below to determine which image-tags are
going to change and thus determine the version delta.

Harbor is a quite active project, so it may make sense mostly to pay attention
to minor/major releases and ignore the changes made in patch-releases.

#### Upgrade Harbor

Harbor documents the general upgrade procedure for non-kubernetes upgrades for minor
versions [on their website](https://goharbor.io/docs/latest/administration/upgrade/).
This documentation is of little use to our Kubernetes setup, but it can be useful
to consult the page for minor/major version upgrades to see if there are any
special considerations to be made.

The Harbor chart repository [has upgrade instructions as well](https://github.com/goharbor/harbor-helm/blob/master/docs/Upgrade.md).
The instructions asks you to do a snapshot of the database and backup the tls
secret. Snapshotting the database is currently out of scope, but could be a thing
that is considered in the future. The tls secret is handled by cert-manager, and
as such does not need to be backed up.

With knowledge of the app version, you can now update `versions.env` as described
in the [General Procedure](#general-procedure) section, diff to see the changes
that are going to be applied, and finally do the actual upgrade.

Diff command

```bash
DIFF=1 task support:provision:harbor
```

Upgrade command

```bash
task support:provision:harbor
```

#### Verify Harbor upgrade

First verify that pods are coming up

```shell
kubectl -n harbor get pods
```

When Harbor seems to be working, you can verify that the UI is working by
accessing <https://harbor.lagoon.dplplat01.dpl.reload.dk/>. The password for
the user `admin` can be retrived with the following command:

```bash
UI_NAME=harbor task ui-password
```

If everything looks good, you can consider to deploying a site. One way to do this
is to identify an existing site of low importance, and re-deploy it. A re-deploy
will require Lagoon to both fetch and push images. Instructions for how to access
the lagoon UI is out of scope of this document, but can be found in the runbook
for [running a lagoon task](run-a-lagoon-task.md). In this case you are looking
for the "Deploy" button on the sites "Deployments" tab.

### Ingress-nginx

#### Comparing ingress-nginx versions

When working with the `ingress-nginx` chart we have at least 3 versions to keep
track off.

The chart version tracks the version of the chart itself. The charts `appVersion`
tracks a `controller` application which dynamically configures a bundles `nginx`.
The version of `nginx` used is determined configuration-files in the controller.
Amongst others the
[ingress-nginx.yaml](https://github.com/kubernetes/ingress-nginx/blob/main/ingress-nginx.yaml).

Link for diffing two chart versions:
<https://github.com/kubernetes/ingress-nginx/compare/helm-chart-4.6.0...helm-chart-4.6.1>

The project keeps a quite good [changelog for the chart](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx/changelog)

Link for diffing two controller versions:
<https://github.com/kubernetes/ingress-nginx/compare/controller-v1.7.1...controller-v1.7.0>

Consult the individual [GitHub releases](https://github.com/kubernetes/ingress-nginx/releases)
for descriptions of what has changed in the controller for a given release.

#### Upgrade ingress-nginx

With knowledge of the app version, you can now update `versions.env` as described
in the [General Procedure](#general-procedure) section, diff to see the changes
that are going to be applied, and finally do the actual upgrade.

Diff command

```bash
DIFF=1 task support:provision:ingress-nginx
```

Upgrade command

```bash
task support:provision:ingress-nginx
```

#### Verify ingress-nginx upgrade

The ingress-controller is very central to the operation of all public accessible
parts of the platform. It's area of resposibillity is on the other hand quite
narrow, so it is easy to verify that it is working as expected.

First verify that pods are coming up

```shell
kubectl -n ingress-nginx get pods
```

Then verify that the ingress-controller is able to serve traffic. This can be
done by accessing the UI of one of the apps that are deployed in the platform.

Access eg. <https://ui.lagoon.dplplat01.dpl.reload.dk/>.

### K8up

We can currently not upgrade to version 2.x of K8up as Lagoon
[is not yet ready](https://docs.lagoon.sh/installing-lagoon/lagoon-backups/#lagoon-backups)

### Loki

#### Comparing Loki versions

The Loki chart is versioned separatly from Loki. The version of Loki installed
by the chart is tracked by its `appVersion`. So when upgrading, you should always
look at the diff between both the chart and app version.

The general upgrade procedure will give you the chart version, access the
following link to get the release note for the chart. Remember to insert your
version:

<https://github.com/grafana/loki/releases/tag/helm-loki-5.5.1>

Notice that the Loki helm-chart is maintained in the same repository as Loki
itself. You can find the diff between the chart versions by comparing two
chart release tags.

<https://github.com/grafana/loki/compare/helm-loki-5.5.0...helm-loki-5.5.1>

As the repository contains changes to Loki itself as well, you should seek out
the file `production/helm/loki/Chart.yaml` which contains the `appVersion` that
defines which version of Loki a given chart release installes.

Direct link to the file for a specific tag:
<https://github.com/grafana/loki/blob/helm-loki-3.3.1/production/helm/loki/Chart.yaml>

With the app-version in hand, you can now look at the
[release notes for Loki](https://github.com/grafana/loki/blob/main/CHANGELOG.md)
to see what has changed between the two appVersions.

Last but not least the Loki project maintains a upgrading guide that can be
found here: <https://grafana.com/docs/loki/latest/upgrading/>

#### Upgrade Loki

Diff command

```bash
DIFF=1 task support:provision:loki
```

Upgrade command

```bash
task support:provision:loki
```

#### Verify Loki upgrade

List pods in the `loki` namespace to see if the upgrade has completed
successfully.

```shell
  kubectl --namespace loki get pods
```

Next verify that Loki is still accessibel from Grafana and collects logs by
logging in to Grafana. Then verify the Loki datasource, and search out some
logs for a site. See the validation steps for [Grafana](#verify-grafana-upgrade)
for instructions on how to access the Grafana UI.

### MinIO

We can currently not upgrade MinIO without loosing the Azure blob gateway.
see:

- <https://blog.min.io/deprecation-of-the-minio-gateway/>
- <https://github.com/minio/minio/issues/14331>
- <https://github.com/bitnami/charts/issues/10258#issuecomment-1132929451>

### Prometheus

#### Comparing Prometheus versions

The `kube-prometheus-stack` helm chart is quite well maintained and is versioned
and developed separately from the application itself.

A specific release of the chart can be accessed via the following link:

<https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-45.27.2>

The chart is developed alongside a number of other community driven prometheus-
related charts in <https://github.com/prometheus-community/helm-charts>.

This means that the following comparison between two releases of the chart
will also contain changes to a number of other charts. You will have to look
for changes in the `charts/kube-prometheus-stack/` directory.

<https://github.com/prometheus-community/helm-charts/compare/kube-prometheus-stack-45.26.0...kube-prometheus-stack-45.27.2>

#### Upgrade Prometheus

The Readme for the chart contains a good [Upgrading Chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md#upgrading-chart)
section that describes things to be aware of when upgrading between specific
minor and major versions. The same documentation can also be found on
[artifact hub](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack).

Consult the section that matches the version you are upgrading from and to. Be
aware that upgrades past a minor version often requires a CRD update. The
CRDs may have to be applied before you can do the diff and upgrade. Once the
CRDs has been applied you are committed to the upgrade as there is no simple
way to downgrade the CRDs.

Diff command

```bash
DIFF=1 task support:provision:prometheus
```

Upgrade command

```bash
task support:provision:prometheus
```

#### Verify Prometheus upgrade

List pods in the `prometheus` namespace to see if the upgrade has completed
successfully. You should expect to see two types of workloads. First a single
a single `promstack-kube-prometheus-operator` pod that runs Prometheus, and then
a `promstack-prometheus-node-exporter` pod for each node in the cluster.

```shell
  kubectl --namespace prometheus get pods -l "release=promstack"
```

As the Prometheus UI is not directly exposed, the easiest way to verify that
Prometheus is running is to access the Grafana UI and verify that the dashboards
that uses Prometheus are working, or as a minimum that the prometheus datasource
passes validation. See the validation steps for [Grafana](#verify-grafana-upgrade)
for instructions on how to access the Grafana UI.

### Promtail

#### Comparing Promtail versions

The Promtail chart is versioned separatly from Promtail which itself is a part of
Loki. The version of Promtail installed by the chart is tracked by its appVersion.
So when upgrading, you should always look at the diff between both the chart and
app version.

The general upgrade procedure will give you the chart version, access the
following link to get the release note for the chart. Remember to insert your
version:

<https://github.com/grafana/helm-charts/releases/tag/promtail-6.6.0>

The note will most likely be empty. Now diff the chart version with the current
version, again replacing the version with the relevant for your releases.

<https://github.com/grafana/helm-charts/compare/promtail-6.6.0...promtail-6.6.1>

As the repository contains a lot of charts, you will need to do a bit of
digging. Look for at least `charts/promtail/Chart.yaml` which can tell you the
app version.

With the app-version in hand, you can now look at the
[release notes for Loki](https://github.com/grafana/loki/blob/main/CHANGELOG.md)
(which promtail is part of). Look for notes in the _Promtail_ sections of the
release notes.

#### Upgrade Promtail

Diff command

```bash
DIFF=1 task support:provision:promtail
```

Upgrade command

```bash
task support:provision:promtail
```

#### Verify Promtail upgrade

List pods in the `promtail` namespace to see if the upgrade has completed
successfully.

```shell
  kubectl --namespace promtail get pods
```

With the pods running, you can verify that the logs are being collected seeking
out logs via Grafana. See the validation steps for [Grafana](#verify-grafana-upgrade)
for details on how to access the Grafana UI.

You can also inspect the logs of the individual pods via

```shell
kubectl --namespace promtail logs -l "app.kubernetes.io/name=promtail"
```

And verify that there are no obvious error messages.
