# Alertmanager Setup

The We use the [alertmanager](architecture/adr-003-system-alerts.md) automatically
ties to the metrics of Prometheus but in order to make it work the configuration
and rules need to be setup.

## Configuration

The configuration is stored in a secret:

```shell
kubectl get secret \
  -n prometheus alertmanager-promstack-kube-prometheus-alertmanager -o yaml
```

In order to update the configuration you need to get the secret resource definition
yaml output and retrieve the `data.alertmanager.yaml` property.

You need to base64 decode the value, update configuration with SMTP settings,
receivers and so forth.

## Rules

It is possible to set up various rules(thresholds), both on cluster level and for
separate containers and namespaces.

Here is a site with examples of rules to get an idea of the
[possibilities](https://awesome-prometheus-alerts.grep.to/rules.html).

## Test

We have tested the setup by making a configuration looking like this:

Get the configuration form the secret as described above.

Change it with smtp settings in order to be able to debug the alerts:

```shell
global:
  resolve_timeout: 5m
  smtp_smarthost: smtp.gmail.com:587
  smtp_from: xxx@xxx.xx
  smtp_auth_username: xxx@xxx.xx
  smtp_auth_password: xxxx
receivers:
- name: default
- name: email-notification
  email_configs:
    - to: xxx@xxx.xx
route:
  group_by:
  - namespace
  group_interval: 5m
  group_wait: 30s
  receiver: default
  repeat_interval: 12h
  routes:
  - match:
      alertname: testing
    receiver: email-notification
  - match:
      severity: critical
    receiver: email-notification
```

Base64 encode the configuration and update the secret with the new configuration
hash.

Find the cluster ip of the alertmanager service running (the service name can
possibly vary):

```sh
kubectl get svc -n prometheus promstack-kube-prometheus-alertmanager
```

And then run a curl command in the cluster (you need to find the IP o):

```shell
# 1.
kubectl run -i --rm --tty debug --image=curlimages/curl --restart=Never -- sh

# 2
curl -XPOST http://[ALERTMANAGER_SERVICE_CLUSTER_IP]:9093/api/v1/alerts \
 -d '[{"status": "firing","labels": {"alertname": "testing","service": "curl",\
 "severity": "critical","instance": "0"},"annotations": {"summary": \
 "This is a summary","description": "This is a description."},"generatorURL": \
 "http://prometheus.int.example.net/<generating_expression>",\
 "startsAt": "2020-07-22T01:05:38+00:00"}]'

```
