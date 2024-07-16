#!/usr/bin/env bash
#
# Lagoon doesn't allow us to set the resource request which results in kubernetes not
# being able to adjust it's workloades properly.
# This script allows us to do that, though in an imperfect way.
# The Script should be obsolote when a vertical pod autoscaler is in place.

# Namespace
NAMESPACES_RAW=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
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
  if [[ " ${SYSTEM_NAMESPACES[@]} " =~ " ${NS} " ]]; then
    continue
  fi
  echo "##   $NS    ##"
  # Pod to be adjusted
  DEPLOYMENTS=("cli" "nginx" "varnish" "redis")

  # Desired memory request
  MEMORY_REQUEST="150Mi"

  for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
    # Patch the deployments resource request
    kubectl patch deployments.apps -n $NS $DEPLOYMENT --type="json" -p='[
      {
        "op": "replace",
        "path": "/spec/template/spec/containers/0/resources/requests/memory",
        "value": "'"$MEMORY_REQUEST"'"
      }
    ]'
  done
done
