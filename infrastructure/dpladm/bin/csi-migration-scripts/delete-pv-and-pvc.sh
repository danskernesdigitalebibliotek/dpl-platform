#!/usr/bin/env bash
#
# This script creates new PersistentVolumeClaims and PersistentVolumes for a namespace
#

set -euo pipefail

NAMESPACES=$(kubectl get ns -l lagoon.sh/controller=lagoon --no-headers | awk '{print $1}')
for NAMESPACE in $NAMESPACES; do
  echo $NAMESPACE
  # Get pvc variable
  PV_NAME=$(kubectl get pv -n $NAMESPACE new-nginx | grep pvc | awk '{print $3}') || true
  echo $PV_NAME
  if [ -z $PV_NAME ]; then
    echo "skipping"
    continue
  fi
  echo $PV_NAME

  # Delete old PVC from namespace
  kubectl delete pvc -n $NAMESPACE new-nginx --wait=false || true
  kubectl patch pvc -n $NAMESPACE new-nginx -p '{"metadata":{"finalizers":null}}' || true
  # Mark old PV as up for deletion
  # kubectl delete pv $PV_NAME  --grace-period=0 --wait=false || true
  # kubectl patch pv $PV_NAME -p '{"metadata":{"finalizers":null}}' || true
  
done
