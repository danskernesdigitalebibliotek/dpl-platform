#!/usr/bin/env bash
#
# Lagoon doesn't allow us to set the resource request which results in kubernetes not
# being able to adjust it's workloades properly.
# This script allows us to do that, though in an imperfect way.
# The Script should be obsolote when a vertical pod autoscaler is in place.

# Namespace
NAMESPACES_RAW=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
# shellcheck disable=SC2206
NAMESPACES=($NAMESPACES_RAW)

SYSTEM_NAMESPACES=(
  "calico-system"
  "cert-manager"
  "default"
  "dpl-cms-develop"
  "grafana"
  "harbor"
  "ingress-nginx"
  "k8up"
  "kube-node-lease"
  "kube-public"
  "kube-system"
  "kuma-monitoring"
  "lagoon"
  "lagoon-core"
  "loki"
  "minio"
  "prometheus"
  "promtail"
  "tigera-operator"
)

echo "Adjusting resource requests in the cluster"
for NS in "${NAMESPACES[@]}"; do
  # Skip system namespaces - those we have enough controll over
  if [[ " ${SYSTEM_NAMESPACES[*]} " =~ ${NS} ]]; then
    continue
  fi
# We also dont want to adjust for DPL-CMS
  if [[ "$NS" = *"dpl-cms"* ]]; then
    continue
  fi
  echo "##   $NS    ##"
  # Pod to be adjusted
  DEPLOYMENTS=("cli" "nginx" "varnish" "redis")

  # Desired memory request
  VARNISH_MEMORY="1000Mi"
  REDIS_MEMORY="100Mi"
  NGINX_MEMORY="150Mi"
  CLI_MEMORY="20Mi"

  for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
    if [ "$DEPLOYMENT" = "cli" ]; then
      MEMORY_REQUEST=$CLI_MEMORY
      echo $MEMORY_REQUEST
    fi
    if [ "$DEPLOYMENT" = "nginx" ]; then
      MEMORY_REQUEST=$NGINX_MEMORY
      echo $MEMORY_REQUEST
    fi
    if [ "$DEPLOYMENT" = "redis" ]; then
      MEMORY_REQUEST=$REDIS_MEMORY
      echo $MEMORY_REQUEST
    fi
    if [ "$DEPLOYMENT" = "varnish" ]; then
      MEMORY_REQUEST=$VARNISH_MEMORY
    fi
    # Patch the deployments resource request
    kubectl patch deployments.apps -n "$NS" "$DEPLOYMENT" --type="json" -p='[
      {
        "op": "replace",
        "path": "/spec/template/spec/containers/0/resources/requests/memory",
        "value": "'"$MEMORY_REQUEST"'"
      }
    ]'
  done
done
