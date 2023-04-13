#!/usr/bin/env bash
#
# Install and configure Harbor
#
#
# See https://github.com/grafana/helm-charts/tree/main/charts/loki
# and https://github.com/grafana/helm-charts/tree/main/charts/promtail
# For more info on the charts.
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
verifyVariable "HARBOR_ADMIN_PASS"
verifyVariable "HARBOR_EXTERNAL_URL"
verifyVariable "HARBOR_HOSTNAME"
verifyVariable "STORAGE_CONTAINER_NAME"
verifyVariable "STORAGE_ACCOUNT_NAME"
verifyVariable "STORAGE_ACCOUNT_KEY"

# Setup values well use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo harbor https://helm.goharbor.io

# Output the version if we're requested to.
outputVersionAndExitIfRequested harbor/harbor "${VERSION_HARBOR}"

# Proceede to provisioning.

# Setup the namespaces.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/harbor/namespace.yaml"
handleApplyDiffExit $?
set -e

# shellcheck disable=SC2016
envsubst '$HARBOR_ADMIN_PASS $HARBOR_EXTERNAL_URL $HARBOR_HOSTNAME $STORAGE_CONTAINER_NAME $STORAGE_ACCOUNT_NAME $STORAGE_ACCOUNT_KEY' \
  < "${configuration_dir}/harbor/harbor-values.template.yaml" \
  > "${configuration_dir}/harbor/harbor-values.yaml"

isDiffing && echo " > Diffing release" || echo " > Installing/upgrading release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  harbor harbor/harbor \
  --namespace harbor \
  --version "${VERSION_HARBOR}" \
  --values "${configuration_dir}/harbor/harbor-values.yaml"

echo " > Done."
