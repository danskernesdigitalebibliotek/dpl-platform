#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail

NAMESPACES=$(kubectl get ns -l lagoon.sh/controller=lagoon --no-headers | awk '{print $1}')
for ns in $NAMESPACES; do
  echo $ns
  kubectl patch -n $ns pvc nginx -p '{
    "metadata": {
      "annotations": {
        "kubectl.kubernetes.io/last-applied-configuration": null
      }
    }
  }' || true
done
