#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail

NAMESPACES=$(kubectl get ns -l lagoon.sh/controller=lagoon --no-headers | awk '{print $1}' | grep main)
VOLUMEHANDLE_PREFIX="/subscriptions/8ac8a259-5bb3-4799-bd1e-455145b12550/resourceGroups/rg-env-dplplat01/providers/Microsoft.Storage/storageAccounts/stdpldplplat01585708af/"
for ns in $NAMESPACES; do
  echo $ns
  # Get pvc variable
  SHARE_NAME=$(kubectl get pvc -n $ns tmp-nginx | grep pvc | awk '{print $3}' | cut -c 5- )
  # echo $SHARE_NAME
  
  PROJECT_NAME=$(echo $ns | rev | cut -c 6- | rev)
  # echo $PROJECT_NAME
  # Set the PV's name  to the new sharename
  volumeName="$SHARE_NAME" yq -i '.metadata.name = strenv(volumeName)' pv.yaml
  # The sharename is the same as we are doing a logical deletion and not a real one
  shareName=$SHARE_NAME yq -i '.spec.csi.volumeAttributes.shareName = strenv(shareName)' pv.yaml
  
  volumeHandle="$VOLUMEHANDLE_PREFIX$SHARE_NAME" yq -i '.spec.csi.volumeHandle = strenv(volumeHandle)' pv.yaml
  namespace=$ns yq -i '.metadata.namespace = strenv(namespace)' pv.yaml
  namespace=$ns yq -i '.spec.csi.nodeStageSecretRef.namespace = strenv(namespace)' pv.yaml
  # cat pv.yaml

  namespace=$ns yq -i '.metadata.namespace = strenv(namespace)' pvc.yaml
  volumeName="$SHARE_NAME" yq -i '.spec.volumeName = strenv(volumeName)' pvc.yaml
  projectName=$PROJECT_NAME yq -i '.metadata.labels."lagoon.sh/project" = strenv(projectName)' pvc.yaml
  # cat pvc.yaml
  kubectl apply -f pv.yaml
  kubectl apply -f pvc.yaml
  
  kubectl patch deployments.apps -n $ns cli -p '{"spec":{"template":{"spec": {"volumes": [{"name": "nginx", "persistentVolumeClaim": { "claimName": "nginx"}}]}}}}'
  kubectl patch deployments.apps -n $ns nginx -p '{"spec":{"template":{"spec": {"volumes": [{"name": "nginx", "persistentVolumeClaim": { "claimName": "nginx"}}]}}}}'
done
