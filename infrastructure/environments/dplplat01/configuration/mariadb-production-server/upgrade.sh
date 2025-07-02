#!/bin/bash

helm upgrade mariadb-production-server . \
  --namespace mariadb-10-06-01-production \
  --create-namespace \
  --install \
  -f values.yaml
