#!/usr/bin/env bash
#
# Install and configure two minio gateways for Azure blob storage
#
# Requires a functional and authenticated kubectl context.
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

# These variables are either pulled in via the environment or versions.env.

# The name of the Helm release, used to allow multiple installs of the chart
# into the same namespace.
verifyVariable "HELM_RELEASE_NAME"

# The credentials the client (eg. lagoon) has to present to minio to gain access.
verifyVariable "CLIENT_ACCESS_KEY"
verifyVariable "CLIENT_SECRET_KEY"

# The credentials minio uses to access Azure.
verifyVariable "STORAGE_ACCOUNT_NAME"
verifyVariable "STORAGE_ACCOUNT_KEY"

# The hostname the API will be accessible on and the ingress class.
verifyVariable "API_HOSTNAME"
verifyVariable "INGRESS_CLASS"

# Setup values we will use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo bitnami https://charts.bitnami.com/bitnami

# Output the version if we're requested to.
outputVersionAndExitIfRequested bitnami/minio "${VERSION_MINIO}"

# Proceede to provisioning.

# Setup the namespace.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/minio/namespace.yaml"
handleApplyDiffExit $?
set -e

# shellcheck disable=SC2016
envsubst '$CLIENT_ACCESS_KEY $CLIENT_SECRET_KEY $STORAGE_ACCOUNT_NAME $STORAGE_ACCOUNT_KEY $API_HOSTNAME $INGRESS_CLASS' \
  < "${configuration_dir}/minio/minio-values.template.yaml" \
  > "${configuration_dir}/minio/minio-values.yaml"

isDiffing && echo " > Diffing release" || echo " > Installing/upgrading release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  "${HELM_RELEASE_NAME}" bitnami/minio \
  --namespace minio \
  --version "${VERSION_MINIO}" \
  --values "${configuration_dir}/minio/minio-values.yaml"

echo " > Done."


