#!/bin/bash

helm upgrade mariadb-servers . \
  --namespace mariadb-servers \
  --create-namespace \
  --install \
  -f values.yaml
