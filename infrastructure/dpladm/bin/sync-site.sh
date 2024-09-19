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


function getWebmasterDplCmsRelease {
    local wmRelease
    wmRelease=$(yq eval ".sites.${1}.moduletest-dpl-cms-release" "${2}")
    if [[ "${wmRelease}" == "null" ]]; then
        echo ""
        return
    fi

    echo "${wmRelease}"
    return
}

function getSiteReleaseImageRepository {
    local repository
    repository=$(yq eval ".sites.${1}.releaseImageRepository" "${2}")
    if [[ "${repository}" == "null" ]]; then
        echo "Error, could not determine releaseImageRepository for ${SITE} in ${SITES_CONFIG}"
        set +e
        return 1
    fi

    echo "${repository}"
    return
}

function getSiteReleaseImageName {
    local imageName
    imageName=$(yq eval ".sites.${1}.releaseImageName" "${2}")
    if [[ "${imageName}" == "null" ]]; then
        echo "Error, could not determine releaseImageName for ${SITE} in ${SITES_CONFIG}"
        set +e
        return 1
    fi

    echo "${imageName}"
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

function getSiteAutogenerateRoutes {
    local autogenerateRoutes
    autogenerateRoutes=$(yq eval ".sites.${1}.autogenerateRoutes" "${2}")
    if [[ "${autogenerateRoutes}" == "null" ]]; then
        echo ""
        return
    fi
    echo "${autogenerateRoutes}"
}

function getSiteImportTranslationsCron {
    local importTranslationsCron
    importTranslationsCron=$(yq eval ".sites.${1}.importTranslationsCron" "${2}")

    if [[ "${importTranslationsCron}" == "null" ]]; then
        echo "M H(2-5) * * *"
        return
    fi

    echo "${importTranslationsCron}"
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

# We're using subshells below, in order to display error-messages we have to
# allow errors, and then pass them on for seperate handling.
set +o errexit
# Get the primary and secondary domains from site.yml.
primaryDomain=$(getSitePrimaryDomain "${SITE}" "${SITES_CONFIG}")
secondaryDomains=$(getSiteSecondaryDomains "${SITE}" "${SITES_CONFIG}")
autogenerateRoutes=$(getSiteAutogenerateRoutes "${SITE}" "${SITES_CONFIG}")
releaseTag=$(getSiteDplCmsRelease "${SITE}" "${SITES_CONFIG}")
wmReleaseTag=$(getWebmasterDplCmsRelease "${SITE}" "${SITES_CONFIG}")
siteImageRepository=$(getSiteReleaseImageRepository "${SITE}" "${SITES_CONFIG}" || exit 1)
failOnErr $? "${siteImageRepository}"
siteReleaseImageName=$(getSiteReleaseImageName "${SITE}" "${SITES_CONFIG}")
failOnErr $? "${siteReleaseImageName}"
plan=$(getSitePlan "${SITE}" "${SITES_CONFIG}")
importTranslationsCron=$(getSiteImportTranslationsCron "${SITE}" "${SITES_CONFIG}")
set -o errexit

# Synchronise the sites environment repository.
syncEnvRepo "${SITE}" "${releaseTag}" "${BRANCH}" "${siteImageRepository}" "${siteReleaseImageName}" "${importTranslationsCron}" "${autogenerateRoutes}" "${primaryDomain}" "${secondaryDomains}"

if [ "${plan}" = "webmaster" ] && [ "${BRANCH}" = "main" ]; then
    syncEnvRepo "${SITE}" "${wmReleaseTag}" "moduletest" "${siteImageRepository}" "${siteReleaseImageName}" "${importTranslationsCron}" "${autogenerateRoutes}" "${primaryDomain}" "${secondaryDomains}"
fi
