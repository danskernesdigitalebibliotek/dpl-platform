# A DPL Platform environment

All resources of a Platform environment is contained in a single Azure Resource
Group. The resources are provisioned via a [Terraform setup](../../dpl-platform/infrastructure/README.md)
that keeps its resources in a separate resource group.

An environment is created in two separate stages. First all required
infrastructure resources are provisioned, then a semi-automated deployment
process carried out which configures all the various software-components that
makes up an environment.

The overview of current platform environments along with the various urls and
a summary of its primary configurations can be found [in the wiki](https://github.com/danskernesdigitalebibliotek/dpl-platform/wiki).

## Environment infrastructure.
![](diagrams/render-png/dpl-platform-azure.png)

A platform environment uses the following Azure infrastructure resources.

- A virtual Network - with a subnet, configured with access to a number of services.
- A Storage account used for storing logs and the file-shares the sites uses.
- A MariaDB used to host the sites databases.
- A Key Vault that holds administrative credentials to resources that Lagoon needs administrative access to.
- An Azure Kubernetes Service cluster that hosts the platform itself.
- Two Public IPs: one for ingress one for egress.

The Azure Kubernetes Service in return creates its own resource group that
contains a number of resources that are automatically managed by the AKS service.
AKS also has a managed control-plane component that is mostly invisible to us.
It has a separate managed identity which we need to grant access to any
additional infrastructure-resources outside the "MC" resource-group that we
need AKS to manage.

## Environment Platform Components

The Platform consists of a number of software components deployed into the
AKS cluster. The components are generally installed via [Helm](https://helm.sh/),
and their configuration controlled via [values-files](https://helm.sh/docs/chart_template_guide/values_files/).

Essential configurations such as the urls for the site can be found [in the wiki](https://github.com/danskernesdigitalebibliotek/dpl-platform/wiki/Platform-Environments)

The following sections will describe the overall role of the component and how
it integrates with other components. For more details on how the component is
configured, consult the corresponding values-file for the component found in
the individual [environments](../infrastructure/environments)  configuration
folder.

![](../../documentation/../dpl-platform/documentation/diagrams/render-png/cluster-support-workloads.png)

### Lagoon
[Lagoon](https://docs.lagoon.sh/lagoon/) is an Open Soured Platform As A Service
created by [Amazee](https://www.amazee.io/). The platform builds on top of a
Kubernetes cluster, and provides features such as automated builds and the
hosting of a large number of sites.

### Ingress Nginx
Kubernetes does not come with an Ingress Controller out of the box. An ingress-
controllers job is to accept traffic approaching the cluster, and route it via
services to pods that has requested ingress traffic.

We use the widely used [Ingress Nginx](vhttps://kubernetes.github.io/ingress-nginx)
Ingress controller.

### Cert Manager
[Cert Manager](https://cert-manager.io/docs/) allows an administrator specify
a request for a TLS certificate, eg. as a part of an Ingress, and have the
request automatically fulfilled.

The platform uses a cert-manager configured to handle certificate requests via
[Let's Encrypt](https://letsencrypt.org/).

### Prometheus and Alertmanager
[Prometheus](https://prometheus.io/) is a timeseries database used by the platform
to store and index runtime metrics from both the platform itself and the sites
running on the platform.

Prometheus is configured to scrape and ingest the following sources
* [Node Exporter](https://github.com/prometheus/node_exporter) (Kubernetes runtime metrics)
* Ingress Nginx

Prometheus is installed via an [Operator](https://github.com/prometheus-operator/prometheus-operator)
which amongst other things allows us to configure Prometheus and Alertmanager via
 `ServiceMonitor` and `AlertmanagerConfig`.

[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) handles
the delivery of alerts produced by Prometheus.

### Grafana
[Grafana](https://grafana.com/oss/grafana/) provides the graphical user-interface
to Prometheus and Loki. It is configured with a number of datasources via its
values-file, which connects it to Prometheus and Loki.

### Loki and Promtail
[Loki](https://grafana.com/oss/loki/) stores and indexes logs produced by the pods
 running in AKS. [Promtail]https://grafana.com/docs/loki/latest/clients/promtail/
streams the logs to Loki, and Loki in turn makes the logs available to the
administrator via Grafana.

## Environment Site Git Repositories
Each platform-site is controlled via a GitHub repository. The repositories are
provisioned via Terraform. The following depicts the authorization and control-
flow in use:
![](diagrams/render-png/github-environment-repositories.png)