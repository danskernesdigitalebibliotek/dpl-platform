#!/usr/bin/env bash
#
# This script finds and deletes all pods that are in a "Completed" state.
# This is harmless as completed pods are never doing any work, and mostly exist
# to allow state inspection. It is, however, nice to be able to get a good
# overview of relevant pods when working directly with the Kubernetes API.


NAMESPACES=$(kubectl get ns --no-headers | awk '{print $1}')

echo "Deleting completed pods in all namespaces"
for NS in $NAMESPACES; do
  echo "## Namespace: $NS"

  COMPLETED_PODS=$(kubectl get pods -n "$NS" --no-headers | grep Completed | awk '{print $1}')
  for POD in $COMPLETED_PODS; do
    echo "¤¤ Pod: $POD";
    kubectl delete pod -n "$NS" "$POD" --wait=false
  done
done
