# Maintenance plan

This document outlines every piece of the platform that need upgrading and
updating.

## Lagoon

Update interval: 1-4 months
Release URL: <https://github.com/uselagoon/lagoon/releases>
Upgrade Docs URL:
Expect downtime: Highly likely
Time to do: Unknown at the time of writing (most likely a day the first time)
Runbook: [Upgrading Lagoon](./runbooks/upgrading-lagoon.md)
Notes:

## AKS

Update interval: monthly
Release URL: <https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli>
Upgrade Docs URL:
  <https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-portal>
Expect downtime: yes, there'll be a very short outage alike to releases
Time to do: 2-6 hours
Runbook: [Update AKS](./runbooks/upgrading-aks.md)
Notes:

## Support Workloads

We have a number of support workloads. Which at the time of writing is all
Helm Charts.
Information on Helm upgrades can be found
on the [Helm website](https://helm.sh/docs/helm/helm_upgrade/).
There's a general runbook for upgrading the support workloads here:
[Upgrade Support Workloads](./runbooks/upgrading-support-workloads.md).

### Cert-manager

Update interval: every 6 months
Release URL: <https://github.com/cert-manager/cert-manager/releases>
Upgrade Docs URL: <https://cert-manager.io/docs/installation/upgrade/>
Expect downtime: Unknown, but likely none
Time to do: Unknown, but likely < 1 hour
Runbook: [Upgrade Cert-manager](./runbooks/upgrading-support-workloads.md#cert-manager).
Notes:

### Grafana

Update interval: Quaterly
Release URL: <https://github.com/grafana/grafana/releases>
Upgrade Docs URL:
Expect downtime: No, maybe a little for Grafana, but nothing that affects the
  libraries.
Time to do: Unknown
Runbook: [Upgrade Grafana](./runbooks/upgrading-support-workloads.md#grafana)
Notes:

### Harbor

Update interval: Half yearly
Release URL: <https://github.com/goharbor/harbor-helm/releases>
Upgrade Docs URL: <https://github.com/goharbor/harbor-helm/blob/main/docs/Upgrade.md>
Expect downtime: Harbor will have downtime, it will affect sites that need
  redeployment as well as developers who firing up and environment.
Time to do: Unknown
Runbook: [Upgrading Harbor](./runbooks/upgrading-support-workloads.md#harbor)
Notes:

### Nginx Ingress Controller

Update interval: Half yearly
Release URL: <https://github.com/kubernetes/ingress-nginx/releases>
Upgrade Docs URL: <https://kubernetes.github.io/ingress-nginx/deploy/upgrade/#with-helm>
Expect downtime: Highly likely
Time to do: Unkonwn
Runbook: [Upgrading Nginx-ingresss](./runbooks/upgrading-support-workloads#ingress-nginx)
Notes:

### K8up

DO NOT UPGRADE.
From time to time we should checkin with this page [K8Up in lagoon](https://docs.lagoon.sh/installing-lagoon/lagoon-backups/#lagoon-backups)
, where they'll hopefully give and update when it is possible to update K8Up
to a later version than version 1.x.x
Check every quarter.

### Loki

Update interval: Half yearly
Release URL: <https://artifacthub.io/packages/helm/grafana/loki>
Upgrade Docs URL: <https://grafana.com/docs/loki/latest/setup/upgrade/>
Expect downtime: Might be some, but nothing that will hit the libraries
Time to do: Unkown
Runbook: [Upgrade Loki](./runbooks/upgrading-support-workloads.md#loki)
Notes:

### Minio

As we're replacing Minio, we will have to do a section on what ever tool
  we're replacing it with.

### Prometheus

Update interval: Half yearly
Release URL: <https://github.com/prometheus-community/helm-charts/releases?q=kube-prometheus-stack&expanded=true>
Upgrade Docs URL: <https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack#upgrading-chart>
Expect downtime: Probably, but nothing the libraries will be affected by
Time to do: Unkown
Runbook: [Upgrading Prometheus](./runbooks/upgrading-support-workloads.md#prometheus)
Notes:

### Promtail

Update interval: Half yearly
Release URL: <https://github.com/grafana/helm-charts/releases?q=promtail&expanded=true>
Upgrade Docs URL: <https://github.com/grafana/helm-charts/blob/main/charts/promtail/README.md#upgrading>
Expect downtime: Probably, but nothing that concerns the libraries.
Time to do: Unknown
Runbook: [Upgrading Promtail](./runbooks/upgrading-support-workloads.md#upgrade-promtail)
Notes:

## DPL Shell parts

The DPL Shell integrates our day to day tools. The ones, that are not upgraded
automatically when a new version of DPL Shell is created, are listed below.
Most of these, if not all, are watched by dependabot on GitHub, so we
are notified about updates pretty quickly.

### Terraform

Update interval: Yearly
Release URL: <https://hub.docker.com/r/hashicorp/terraform/tags?page=1&ordering=last_updated>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes:

### Azure CLI

Update interval: Half yearly
Release URL: <https://mcr.microsoft.com/v2/azure-cli/tags/list>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes:

### kubelogin

Update interval: Quarterly
Release URL: <https://github.com/Azure/kubelogin/releases>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes:

### Task

Update interval: Half yearly
Release URL: <https://github.com/go-task/task/releases>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes:

### Lagoon CLI

Update interval: Quarterly
Release URL: <https://github.com/uselagoon/lagoon-cli/releases>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes: Dependabot has not as of yet notified us of any available updates,
  so we have to check manually.

### Helm

Update interval: Quarterly
Release URL: <https://hub.docker.com/r/alpine/helm/tags?page=1&ordering=last_updated>
Expect downtime: None
Time to do: 1 hour
Runbook:
Notes:
