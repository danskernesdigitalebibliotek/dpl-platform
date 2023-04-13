#!/usr/bin/env bash
#
# Install and configure Prometheus.
#
# Requires a functional and authenticated kubectl context.
#
# See https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
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

# Setup values well use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo prometheus-community https://prometheus-community.github.io/helm-charts

# Output the version if we're requested to.
outputVersionAndExitIfRequested prometheus-community/kube-prometheus-stack "${VERSION_PROMETHEUS}"

# Proceede to provisioning.

# Setup the namespaces.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/prometheus/namespace.yaml"
handleApplyDiffExit $?
set -e

isDiffing && echo " > Diffing release" || echo " > Installing/upgrading release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
   promstack prometheus-community/kube-prometheus-stack \
  --namespace=prometheus \
  --version "${VERSION_PROMETHEUS}" \
  --values "${configuration_dir}/prometheus/prometheus-values.yaml"

echo " > Done."
