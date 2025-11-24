#!/usr/bin/env bash

# used to bootstrap the app of apps

helm template argo-cd-resources . -n argo-cd | kubectl apply -f -
