# Maintenance plan

This document outlines every piece of the platform that need upgrading and
updating.

## Lagoon

Update interval: 1-4 months
Release URL: <https://github.com/uselagoon/lagoon/releases>
Upgrade Docs URL:
Expect downtime: Highly likely
Time to do: Unknown at the time of writing (most likely a day the first time)
Runbook:
Notes:

## AKS

Update interval: monthly
Release URL: <https://kubernetes.io/releases/>
Upgrade Docs URL:
  <https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-portal>
Expect downtime: yes, there'll be a very short outage alike to releases
Time to do: 2-6 hours
Runbook: [Update AKS](./runbooks/upgrading-aks.md)
Notes:

## Actions/checkout

## Helm charts

We have some Helm charts that requires upgrades.
Information on Helm upgrades can be found
on the [Helm website](https://helm.sh/docs/helm/helm_upgrade/)

### Cert-manager

### Grafana

### Harbor

### Ingress Nginx

### Lagoon Remote

### Lagoon Core

### Loki

### Promstack

### Promtail

### K8Up

## DPL Shell parts

### Terraform

### Azure CLI

### KubeCTL

### Krew

### Task

### Lagoon CLI

### Helm
