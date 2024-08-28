#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail

NAMESPACES=$(kubectl get ns -l lagoon.sh/controller=lagoon --no-headers | awk '{print $1}' )

for ns in $NAMESPACES; do
  echo $ns
  kubectl patch deployments.apps -n $ns nginx -p '{"spec":{"template":{"spec": {"volumes": [{"name": "nginx", "persistentVolumeClaim": { "claimName": "tmp-nginx"}}]}}}}'
done
