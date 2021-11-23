#!/usr/bin/env bash
#
# Install and configure two k8up gateways for Azure blob storage
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
# The credentials the client (eg. lagoon) has to present to k8up to gain access.
verifyVariable "BACKUP_API_URL"
verifyVariable "RESTORE_API_URL"
verifyVariable "BACKUP_CLIENT_ACCESS_KEY"
verifyVariable "BACKUP_CLIENT_SECRET_KEY"
verifyVariable "RESTORE_CLIENT_ACCESS_KEY"
verifyVariable "RESTORE_CLIENT_SECRET_KEY"
verifyVariable "K8UP_GLOBALSTATSURL"
verifyVariable "LAGOON_BACKUP_HANDLER_URL"

# Setup values we will use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Proceede to provisioning.

# Setup the namespace.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/k8up/namespace.yaml"
handleApplyDiffExit $?
set -e

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo appuio https://charts.appuio.ch

# shellcheck disable=SC2016
envsubst '$BACKUP_API_URL $RESTORE_API_URL $BACKUP_CLIENT_ACCESS_KEY $BACKUP_CLIENT_SECRET_KEY $RESTORE_CLIENT_ACCESS_KEY $RESTORE_CLIENT_SECRET_KEY $K8UP_GLOBALSTATSURL $LAGOON_BACKUP_HANDLER_URL' \
  < "${configuration_dir}/k8up/k8up-values.template.yaml" \
  > "${configuration_dir}/k8up/k8up-values.yaml"

isDiffing && echo " > Diffing release"
kubectl "${apply_or_diff}" -f "https://github.com/vshn/k8up/releases/download/v1.2.0/k8up-crd.yaml"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  k8up appuio/k8up \
  --namespace k8up \
  --version "${VERSION_K8UP}" \
  --values "${configuration_dir}/k8up/k8up-values.yaml"

echo " > Done."

