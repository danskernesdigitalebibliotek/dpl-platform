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

function print_usage {
    # Start with a more specific error-message if we're passed the name of a
    # variable that was missing.
    if [[ -n "${1:-}" ]]; then
        echo "Could not find the variable ${1}"
    fi
    echo
    echo "Set the following environment variables before running the script."
    echo "  SITES_CONFIG: path to the sites.yaml that should be used for site configuration"
    echo "  SITE:         the sites key in sites.yaml"
    echo ""
    echo "  FORCE:  Push even if there is no diff in which case an empty"
    echo "          commit will be pushed."

    exit 1
}

function getSiteConfig {
    local config
    config=$(yq eval ".sites.${1}" "${2}")
    if [[ "${config}" == "null" ]]; then
        echo ""
        return
    fi

    echo "${config}"
    return
}

function getSiteDplCmsRelease {
    local release
    release=$(yq eval ".sites.${1}.dpl-cms-release" "${2}")
    if [[ "${release}" == "null" ]]; then
        echo ""
        return
    fi

    echo "${release}"
    return
}

function getSitePrimaryDomain {
    local domain
    domain=$(yq eval ".sites.${1}.primary-domain" "${2}")
    if [[ "${domain}" == "null" ]]; then
        echo ""
        return
    fi

    echo "${domain}"
    return
}

function getSiteSecondaryDomains {
    local domains
    domains=$(yq eval ".sites.${1}.secondary-domains" "${2}")
    if [[ "${domains}" == "null" ]]; then
        echo ""
        return
    fi

    echo "${domains}" | yq eval "join(\" \")" -
    return
}

if [[ -z "${SITES_CONFIG:-}" ]]; then
    print_usage "SITES_CONFIG"
fi

if [[ -z "${SITE:-}" ]]; then
    print_usage "SITE"
fi

# Default to the main branch.
BRANCH=${BRANCH:-main}

if [[ ! -f "${SITES_CONFIG}" ]]; then
    echo "Could not find the file ${SITES_CONFIG}"
    print_usage
fi

siteConfig=$(getSiteConfig "${SITE}" "${SITES_CONFIG}")

if [[ -z "${siteConfig}" ]]; then
    echo "Error, could not look up ${SITE} in ${SITES_CONFIG}"
    exit 1
fi
# Get the primary and secondary domains from site.yml.

primaryDomain=$(getSitePrimaryDomain "${SITE}" "${SITES_CONFIG}")
secondaryDomains=$(getSiteSecondaryDomains "${SITE}" "${SITES_CONFIG}")
releaseTag=$(getSiteDplCmsRelease "${SITE}" "${SITES_CONFIG}")


# Synchronise the sites environment repository.
syncEnvRepo "${SITE}" "${releaseTag}" "${BRANCH}" "${primaryDomain}" "${secondaryDomains}"
