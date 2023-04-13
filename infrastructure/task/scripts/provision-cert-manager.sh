#!/usr/bin/env bash
#
# Provision Cert Manager
#
# Installs and configures Cert Manager into a cluster
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
verifyVariable "VERSION_CERT_MANAGER"

# Setup values well use troughout the scripts
diff_or_nothing=$(ifDiffTernary "diff")
apply_or_diff=$(ifDiffTernary "diff" "apply" )
configuration_dir=$(getConfigurationDir)

# Install the Helm repo, we'll need this regardless of whether we're diffing.
setupHelmRepo jetstack https://charts.jetstack.io

# Output the version if we're requested to.
outputVersionAndExitIfRequested jetstack/cert-manager "${VERSION_CERT_MANAGER}"

# Proceede to provisioning.

# Diff will have an non-zero exitcode on diff, so we have to disable our normal
# "fail on exitcode > 0" behaviour.
set +e

# Setup the namespace.
kubectl "${apply_or_diff}" -f "${configuration_dir}/cert-manager/namespace.yaml"
handleApplyDiffExit $?
set -e

isDiffing && echo " > Diffing release" || echo " > Installing/upgrading release"
# shellcheck disable=SC2086 # We need diff_or_nothing to be unquoted
helm ${diff_or_nothing} upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version "${VERSION_CERT_MANAGER}" \
  --values "${configuration_dir}/cert-manager/cert-manager-values.yaml"

# Wait for certmanager to be ready.
isDiffing || echo " > Waiting for controller to be ready"
isDiffing || kubectl wait \
  --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

isDiffing || kubectl wait \
  --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=cainjector \
  --timeout=300s

isDiffing || kubectl wait \
  --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=webhook \
  --timeout=300s

isDiffing || echo " > Applying staging and production issuers"
isDiffing && echo " > Diffing issuers"

set +e
kubectl "${apply_or_diff}" -f "${configuration_dir}/cert-manager/issuer-production.yaml"
handleApplyDiffExit $?

kubectl "${apply_or_diff}" -f "${configuration_dir}/cert-manager/issuer-staging.yaml"
handleApplyDiffExit $?

echo " > Done."
