#!/usr/bin/env bash
#
# Install and configure Loki and promtail we use to ship logs into loki.
#
# Requires a functional and authenticated kubectl context.
#
# See https://github.com/grafana/helm-charts/tree/main/charts/grafana
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

# Proceede to provisioning.

# Setup the namespaces.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/grafana/namespace.yaml"
handleApplyDiffExit $?
set -e

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo grafana https://grafana.github.io/helm-charts

isDiffing && echo " > Diffing release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  grafana grafana/grafana \
  --namespace grafana \
  --version "${VERSION_GRAFANA}" \
  --values "${configuration_dir}/grafana/grafana-values.yaml"

echo " > Done."
