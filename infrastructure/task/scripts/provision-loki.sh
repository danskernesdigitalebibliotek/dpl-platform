#!/usr/bin/env bash
#
# Install and configure Loki.
#
# Requires a functional and authenticated kubectl context.
#
# See https://github.com/grafana/helm-charts/tree/main/charts/loki
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
verifyVariable "STORAGE_CONTAINER_NAME"
verifyVariable "STORAGE_ACCOUNT_NAME"
verifyVariable "STORAGE_ACCOUNT_KEY"

# Setup values well use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo grafana https://grafana.github.io/helm-charts

# Output the version if we're requested to.
outputVersionAndExitIfRequested grafana/loki "${VERSION_LOKI}"

# Proceede to provisioning.

# Setup the namespaces.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/loki/namespace.yaml"
handleApplyDiffExit $?
set -e

# shellcheck disable=SC2016
envsubst '$STORAGE_CONTAINER_NAME $STORAGE_ACCOUNT_NAME $STORAGE_ACCOUNT_KEY' \
  < "${configuration_dir}/loki/loki-values.template.yaml" \
  > "${configuration_dir}/loki/loki-values.yaml"

isDiffing && echo " > Diffing release" || echo " > Installing/upgrading release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  loki grafana/loki \
  --namespace loki \
  --version "${VERSION_LOKI}" \
  --values "${configuration_dir}/loki/loki-values.yaml"

echo " > Done."
