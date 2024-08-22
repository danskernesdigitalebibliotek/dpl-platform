#!/usr/bin/env bash
#
# This script creates new PersistentVolumeClaims and PersistentVolumes for a namespace
#

set -euo pipefail

function deleteOldPvAndPvc() {
  local NAMESPACE=$1
  local VOLUME_NAME=$2
  local PVC_NAME=$3
  # Delete old PVC from namespace
  kubectl delete pvc -n $NAMESPACE $PVC_NAME --wait=false
  kubectl patch pvc -n $NAMESPACE $PVC_NAME -p '{"metadata":{"finalizers":null}}'
  # Mark old PV as up for deletion
  kubectl delete pv $VOLUME_NAME  --grace-period=0 --wait=false
  kubectl patch pv $VOLUME_NAME -p '{"metadata":{"finalizers":null}}'
}
