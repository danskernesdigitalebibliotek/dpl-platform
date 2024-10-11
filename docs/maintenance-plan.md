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

Update interval: weekly-monthly
Release URL: <https://github.com/cert-manager/cert-manager/releases>
Upgrade Docs URL: <https://cert-manager.io/docs/installation/upgrade/>
Expect downtime: Unknown, but likely none
Time to do: Unknown, but likely < 1 hour
Runbook: [Upgrade Cert-manager](./runbooks/upgrading-support-workloads.md#cert-manager).
Notes:

### Grafana

Update interval: weekly
Release URL: <https://github.com/grafana/grafana/releases>
Upgrade Docs URL:
Expect downtime: No, maybe a little for Grafana, but nothing that affects the
  libraries.
Time to do: Unknown
Runbook: [Upgrade Grafana](./runbooks/upgrading-support-workloads.md#grafana)
Notes:

### Harbor

Update interval: somewhat monthly
Release URL: <https://github.com/goharbor/harbor-helm/releases>
Upgrade Docs URL: <https://github.com/goharbor/harbor-helm/blob/main/docs/Upgrade.md>
Expect downtime: Harbor will have downtime, it will affect sites that need
  redeployment as well as developers who firing up and environment.
Time to do: Unknown
Runbook: [Upgrading Harboar](./runbooks/upgrading-support-workloads.md#harbor)
Notes:

### Ingress Nginx

Update interval: Monthly
Release URL: <https://github.com/kubernetes/ingress-nginx/releases>
Upgrade Docs URL: <https://kubernetes.github.io/ingress-nginx/deploy/upgrade/#with-helm>
Expect downtime: Highly likely
Time to do: Unkonwn
Runbook: [Upgrading Nginx-ingresss](./runbooks/upgrading-support-workloads#ingress-nginx)
Notes:

### K8up

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Loki

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Minio

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Prometheus

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Promtail

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

## DPL Shell parts

The DPL Shell integrates our day to day tools. The ones, that are not upgraded
automatically when a new version of DPL Shell is created, are listed below.
Most of these, if not all, are watched by dependabot on GitHub, so we
are notified about updates pretty quickly.

### Terraform

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Azure CLI

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### KubeCTL

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Krew

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Task

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Lagoon CLI

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:

### Helm

Update interval:
Release URL:
Upgrade Docs URL:
Expect downtime:
Time to do:
Runbook:
Notes:
