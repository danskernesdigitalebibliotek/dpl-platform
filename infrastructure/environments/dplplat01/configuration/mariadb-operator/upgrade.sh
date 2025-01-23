#!/bin/env bash

helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator

helm upgrade mariadb-operator-crds mariadb-operator/mariadb-operator-crds \
  --install \
  --version 0.36.0

helm upgrade mariadb-operator mariadb-operator/mariadb-operator \
  --namespace mariadb-operator \
  --create-namespace \
  --install \
  --version 0.36.0 \
  -f values.yaml
