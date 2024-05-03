#!/usr/bin/env bash
#
# Reads in a sites.yaml and updates the sites environment repository to bring it
# in sync with the configuration with regards to eg. the deployed release.
# This will typically trigger a deployment of the site.
#
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/dpladm-shared.source"

if [[ -z "${SITES_CONFIG:-}" ]]; then
    print_usage "SITES_CONFIG"
fi

if [[ -z "${SITE:-}" ]]; then
    print_usage "SITE"
fi

setUpHorizontalAutoscaler "$SITE" "$SITES_CONFIG"
