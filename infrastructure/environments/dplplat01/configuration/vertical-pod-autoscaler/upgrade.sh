#!/usr/bin/env bash

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update

helm upgrade vpa fairwinds-stable/vpa \
  --install \
  --namespace vpa \
  --create-namespace \
  --version 4.7.0 \
  -f values.yaml
