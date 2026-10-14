# Persisting Grafana dashboards

This guide will tell you how to persist dashboards to survive upgrades and
migrations to new instances of Grafana.

## Overview of the task

1. Create a `GrafanaDashboard` kind file in the /gitops folder
2. Get the JSON that forms the board
3. Add the JSON
4. Escape double curlies
5. Make a PR

### 1. Create a `GrafanaDashboard` kind file

1. Create a YAML file in gitops/dplplat02/grafana/template
2. Add the the following YAML to the file
`apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: name-of-the-board
spec:
  resyncPeriod: 30s
  instanceSelector:
    matchLabels:
      dashboards: "grafana" <--- do not change this!
  json: >`

### 2. Get the JSON that forms the board

1. Go to the board you want to persist
2. Press the 'export' button, and select 'as code' option
3. Copy the full JSON body

### 3. Add the JSON

1. Go the `GrafanaDashboard` file
2. Put the cursor underneath the `json: >` and paste the JSON contents.
Make sure to indent it properly.

### 4. Escape the double curlies

The double curlies, holding variables, needs to be escaped. Otherwise Argo
can't deploy the dashboard. This is done by replacing {{ someVar }} with
{{ "{{someVar}}" }}.

### 5. Make a PR

Sent a PR. This step matters because the operations team needs to ensure the
deployment of the Dashboard.
