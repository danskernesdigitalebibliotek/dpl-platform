#!/usr/bin/env bash

# used to bootstrap the app of apps
kubectl create namespace argo-cd
helm template argo-cd . -n argo-cd | kubectl apply -f -
