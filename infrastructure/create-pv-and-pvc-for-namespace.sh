#!/usr/bin/env bash
#
# This script creates new PersistentVolumeClaims and PersistentVolumes for a namespace
#

set -euo pipefail

source ./deleteOldPvAndPvc.sh

# Test the entered namespace for good measure
kubectl get ns $1

echo "Adding new PVC and PV to $1"

#Get the volume name of the PV
VOLUME_NAME=$(kubectl get pvc -n $1 nginx | grep pvc | awk '{print $3}')
# Change it's name slighty so we can recognize it from the old ones
NEW="new-"
NEW_VOLUME_NAME=${NEW}${VOLUME_NAME}
echo $NEW_VOLUME_NAME

# Set the PVC's volumeName to the new volume name
volumeName=$NEW_VOLUME_NAME yq -i '.spec.volumeName = strenv(volumeName)' pvc.yaml
namespace=$1 yq -i '.metadata.namespace = strenv(namespace)' pvc.yaml

# Set the PV's name and sharename to the new volume name
volumeName=$NEW_VOLUME_NAME yq -i '
  .metadata.name = strenv(volumeName) |
  .spec.csi.volumeAttributes.shareName = strenv(volumeName)
  ' pv.yaml

# Apply the new PV and PVC to the cluster
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

# Switch the nginx deployments nginx volume to use the new PVC
kubectl patch deployments.apps -n $1 nginx -p '{"spec":{"template":{"spec": {"volumes": [{"name": "nginx", "persistentVolumeClaim": { "claimName": "nginx"}}]}}}}'

echo "$1 is now using the intermediary SC via it's new PVC and PV. The Nginx has been patched and new pods spun up"

echo "Proceeding to remove the now obsolete PV and PVC from the namespace $1"

deleteOldPvAndPvc $1 $NEW_VOLUME_NAME "new-nginx"

echo ######## Done ########
