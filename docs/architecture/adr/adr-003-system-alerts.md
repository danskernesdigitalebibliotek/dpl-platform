# ADR-003 System alerts

## Context

There has been a wish for a functionality that alerts administrators if certain
system values have gone beyond defined thresholds rules.

## Decision

We have decided to use [alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
that is a part of the [Prometheus package](https://prometheus.io/) that is
already used for monitoring the cluster.

## Consequences

- We have tried to install alertmanager and [testing it](../alertmanager-setup.md).
  It works and given the various possibilities of defining
  [alert rules](https://awesome-prometheus-alerts.grep.to/rules.html) we consider
  the demands to be fulfilled.
- We will be able to get alerts regarding thresholds on both container and
  cluster level which is what we need.
- Alertmanager fits in the general focus of being cloud agnostic. It is
  [CNCF approved](https://www.cncf.io/announcements/2018/08/09/prometheus-graduates)
  and does not have any external infrastructure dependencies.
