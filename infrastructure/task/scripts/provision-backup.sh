#!/usr/bin/env bash
#
# Install and configure k8up which is used fro Lagoons backup of files and databases.
# Requires a functional and authenticated kubectl context.
#
# See https://artifacthub.io/packages/helm/appuio/k8up
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

# https://github.com/minio/operator/tree/master/helm/minio-operator
helm repo add minio https://operator.min.io/
helm install --namespace minio-operator --create-namespace --generate-name minio/minio-operator
kubectl apply -f https://raw.githubusercontent.com/minio/operator/master/examples/kustomization/tenant-lite/tenant.yaml


# # These variables are either pulled in via the environment or versions.env.
# verifyVariable "STORAGE_CONTAINER_NAME"
# verifyVariable "STORAGE_ACCOUNT_NAME"
# verifyVariable "STORAGE_ACCOUNT_KEY"

# # Setup values well use troughout the scripts
# diff_or_nothing=$(ifDiffTernary "diff")
# configuration_dir=$(getConfigurationDir)
# apply_or_diff=$(ifDiffTernary "diff" "apply" )

# # Proceede to provisioning.

# # Setup the namespaces.
# set +e
# kubectl "${apply_or_diff}" -f "${configuration_dir}/k8up/namespace.yaml"
# handleApplyDiffExit $?
# set -e

# # Install the Helm repo, we'll need this regardless of whether we're diffing.
# setupHelmRepo appuio https://charts.appuio.ch

# # shellcheck disable=SC2016
# envsubst '$STORAGE_CONTAINER_NAME $STORAGE_ACCOUNT_NAME $STORAGE_ACCOUNT_KEY' \
#   < "${configuration_dir}/k8up/k8up-values.template.yaml" \
#   > "${configuration_dir}/k8up/k8up-values.yaml"

# isDiffing && echo " > Diffing release"

# kubectl apply -f https://github.com/vshn/k8up/releases/download/v1.1.0/k8up-crd.yaml

# # shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
# helm ${diff_or_nothing} upgrade --install \
#   k8up appuio/k8up \
#   --namespace k8up \
#   --version "${VERSION_K8UP}" \
#   --values "${configuration_dir}/k8up/k8up-values.yaml"

echo " > Done."
