#!/usr/bin/env bash
#
# Setup a bulk Azure Files storageclass
#
# Configures a storage-class that connects to an Azure Files share.
set -euo pipefail

IFS=$'\n\t'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=./util.source.sh
source "${SCRIPT_DIR}/util.source.sh"

# Determine the platform environment.
if [[ -z "${DPLPLAT_ENV:-}" ]] ; then
    echo "Missing DPLPLAT_ENV environment variable"
    exit 1
fi

# Pull in the environment-specific versions and verify we have what we need.
# shellcheck source=/dev/null
source "$(getVersionsEnv)"

# These variables are either pulled in via the environment.
verifyVariable "RESOURCE_GROUP"
verifyVariable "STORAGE_ACCOUNT_NAME"
verifyVariable "STORAGE_ACCOUNT_KEY"

# Setup values well use troughout the scripts
apply_or_diff=$(ifDiffTernary "diff" "apply" )
configuration_dir=$(getConfigurationDir)

# Proceede to provisioning.

isDiffing || echo "Applying StorageClass"
isDiffing && echo "Diffing StorageClass"

storage_class_template=$(cat <<EOT
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: bulk
provisioner: kubernetes.io/azure-file
reclaimPolicy: Retain
allowVolumeExpansion: true
parameters:
  skuName: Standard_LRS
  storageAccount: \$STORAGE_ACCOUNT_NAME
  resourcegroup: \$RESOURCE_GROUP
EOT
)

# Diff will have an non-zero exitcode on diff, so we have to disable our normal
# "fail on exitcode > 0" behaviour.
set +e

# shellcheck disable=SC2016 # we're passing the dollar-sings on purpose
echo "${storage_class_template}" \
  | envsubst '$RESOURCE_GROUP $STORAGE_ACCOUNT_NAME' \
  | kubectl "${apply_or_diff}" -f -
handleApplyDiffExit $?

# Use kubectl instead of a static manifest-file to get the base64 handling.
isDiffing || echo "Applying storage Secret"
isDiffing && echo "Diffing storage Secret"
kubectl create secret generic bulk \
  --from-literal=sharename="${STORAGE_ACCOUNT_NAME}" \
  --from-literal=azurestorageaccountname="${STORAGE_ACCOUNT_NAME}" \
  --from-literal=azurestorageaccountkey="${STORAGE_ACCOUNT_KEY}"  \
  -o yaml \
  --dry-run=client \
  | kubectl "${apply_or_diff}" -n kube-system -f -
set -e
echo " > Done."
