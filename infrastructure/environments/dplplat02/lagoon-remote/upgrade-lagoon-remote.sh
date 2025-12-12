#!/usr/bin/env bash

kubectl config use-context dplplat02
helm repo add lagoon https://uselagoon.github.io/lagoon-charts/
helm repo update

# Lagoon remote must be installed into a namespace named "Lagoon": https://github.com/uselagoon/lagoon-charts/blob/main/charts/lagoon-remote/README.md#install
sops -d values.sops.yaml | helm upgrade lagoon-remote lagoon/lagoon-remote --install -f - --version 0.89.0 --namespace lagoon --debug
