#!/usr/bin/env bash
#
# Install and configure the Ingress Nginx Ingress Controller
#
# Requires a functional and authenticated kubectl context.
# See https://kubernetes.github.io/ingress-nginx/ for more info.
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
verifyVariable "RESOURCE_GROUP"
verifyVariable "INGRESS_IP"
verifyVariable "VERSION_INGRESS_NGINX"

# Setup values well use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
configuration_dir=$(getConfigurationDir)
apply_or_diff=$(ifDiffTernary "diff" "apply" )

# Proceede to provisioning.

# Setup the namespace.
set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/ingress-nginx/namespace.yaml"
handleApplyDiffExit $?
set -e

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo ingress-nginx https://kubernetes.github.io/ingress-nginx

# shellcheck disable=SC2016
envsubst '$RESOURCE_GROUP $INGRESS_IP' \
  < "${configuration_dir}/ingress-nginx/ingres-nginx-values.template.yaml" \
  > "${configuration_dir}/ingress-nginx/ingres-nginx-values.yaml"

isDiffing && echo " > Diffing release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --version "${VERSION_INGRESS_NGINX}" \
  --values "${configuration_dir}/ingress-nginx/ingres-nginx-values.yaml"

echo " > Done."
