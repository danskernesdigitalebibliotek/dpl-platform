#!/usr/bin/env bash
#
# This script creates new PersistentVolumeClaims and PersistentVolumes for a namespace
#

set -euo pipefail

function backupAndDeleteOldPvAndPvc() {
  local NAMESPACE=$1
  local VOLUME_NAME=$2
  local PVC_NAME=$3

  # Backup the the old PVC and PV before deleting them
  kubectl get pvc -n $NAMESPACE $PVC_NAME -o yaml > "./pvAndPvcBackup/${NAMESPACE}_${PVC_NAME}.yaml"
  kubectl get pv $VOLUME_NAME -o yaml > "./pvAndPvcBackup/${NAMESPACE}_${VOLUME_NAME}"
  # Delete old PVC from namespace
  kubectl delete pvc -n $NAMESPACE $PVC_NAME --wait=false
  kubectl patch pvc -n $NAMESPACE $PVC_NAME -p '{"metadata":{"finalizers":null}}'
  # Mark old PV as up for deletion
  kubectl delete pv $VOLUME_NAME  --grace-period=0 --wait=false
  kubectl patch pv $VOLUME_NAME -p '{"metadata":{"finalizers":null}}'
}
