#!/usr/bin/env bash

helm repo add lagoon https://uselagoon.github.io/lagoon-charts/
helm repo update

sops -d values.sops.yaml | helm diff upgrade lagoon-remote lagoon/lagoon-remote --install -f - --version 0.89.0 --namespace lagoon --dry-run=server --debug
