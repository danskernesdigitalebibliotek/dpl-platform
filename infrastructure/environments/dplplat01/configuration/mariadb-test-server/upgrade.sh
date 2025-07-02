#!/bin/bash

helm upgrade mariadb-servers . \
  --namespace mariadb-10-06-01-test \
  --create-namespace \
  --install \
  -f values.yaml
