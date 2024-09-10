#!/usr/bin/env bash
#
# Lagoon doesn't allow us to set tolerations on our workloads, so we set them
# manually with this script. During adoption of the production-only nodes, we
# can gradually promote workloads to the production nodes by adding them to the
# below list of namespaces.

PROMOTED_NAMESPACES=("canary-main")

DEPLOYMENTS=("cli" "nginx" "varnish" "redis")

NAMESPACES_RAW=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
# shellcheck disable=SC2206
NAMESPACES=($NAMESPACES_RAW)

echo "Patching tolerations on all promoted namespace workloads to schedule on production nodes"
for NS in "${NAMESPACES[@]}"; do

  # Only patch promoted namespaces
  if [[ " ${PROMOTED_NAMESPACES[*]} " =~ ${NS} ]]; then
    echo "## Namespace: $NS"

    for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
      kubectl patch deployments.apps -n "$NS" "$DEPLOYMENT" -p '{"spec": {"template": {"spec": {"tolerations": [{ "key": "noderole.dplplatform", "operator": "Equal", "value": "prod", "effect": "NoSchedule" }]}}}}'
    done
  fi
done
