#!/usr/bin/env bash

kubectl config use-context aks-dplplat01-01
helm repo add lagoon https://uselagoon.github.io/lagoon-charts/
helm repo update

sops -d lagoon-core.values.sops.yaml | helm diff upgrade lagoon-core lagoon/lagoon-core --install -f - --version 1.45.0 --namespace lagoon-core --dry-run --debug
