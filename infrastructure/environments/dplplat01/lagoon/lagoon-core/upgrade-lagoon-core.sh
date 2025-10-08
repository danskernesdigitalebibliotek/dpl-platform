#!/usr/bin/env bash

helm repo add lagoon https://uselagoon.github.io/lagoon-charts/
helm repo update

sops -d lagoon-core.values.sops.yaml | helm diff upgrade lagoon-core lagoon/lagoon-core --install -f - --version 1.41.0 --namespace lagoon-core --dry-run=server --debug
