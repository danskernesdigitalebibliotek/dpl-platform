#!/usr/bin/env bash
#
# Extract the versions of our various tools from the cluster.

set -eEuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

source "util.source.sh"

# We feed shellcheck the versions env from dplplat01 even though getVersionsEnv
# might return the file for a different environent.
# shellcheck source=../../environments/dplplat01/configuration/versions.env
source "$(getVersionsEnv)"

# These are the versions we know about and that we will check against in the
# following code. We keep a separate list to be able to detect if someone adds
# a version to version.env we do not know about.
declare -a known_versions=(
  VERSION_CERT_MANAGER
  VERSION_GRAFANA
  VERSION_HARBOR
  VERSION_INGRESS_NGINX
  VERSION_K8UP
  VERSION_LOKI
  VERSION_MINIO
  VERSION_PROMETHEUS
  VERSION_PROMTAIL
)

# Get a list of all existing VERSION_ variables and check that we know about them.
for version_variable in $(compgen -A variable | grep -E "^VERSION_" | cut -d= -f0); do
    # Check version_variable is in the known_versions array
    # We're intentionally rendering the array into a string and doing string-matching
    # to spot the version_variable in the string. Shellcheck is not happy about
    # this so we have to disable some protections.
    # shellcheck disable=SC2076,SC2199
    if [[ ! " ${known_versions[@]} " =~ " ${version_variable} " ]]; then
        echo "ERROR: ${version_variable} is not a known version variable"
        exit 1
    fi
done





