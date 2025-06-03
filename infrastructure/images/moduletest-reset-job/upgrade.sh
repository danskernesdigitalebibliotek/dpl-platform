#!/bin/env bash

helm upgrade moduletest-reset . \
  --namespace moduletest-reset \
  --create-namespace \
  --install \
  -f values.yaml
