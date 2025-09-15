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

function getGoRelease {
    local goRelease
    # get the version instad - if no version no GO
    goRelease=$(yq eval ".sites.${1}.go-release" "${2}")
     if [[ "${goRelease}" == "null" ]]; then
        echo ""
        return
    fi
    if [[ -z "${goRelease}" ]]; then
        echo "Error: goRelease should have a boolean value"
        exit 1
    fi
    if [[ "${goRelease}" ]]; then
        echo "$goRelease"
        return
    fi
    echo "Error: goRelease somehow emtpy but this wasen't captured"
    exit 1
}

function getDiskSize {
    local diskSize
    # get the version instad - if no version no GO
    diskSize=$(yq eval ".sites.${1}.diskSize" "${2}")
    #  if [[ "${diskSize}" == "null" ]]; then
    #     echo ""
    #     return
    # fi
    # if [[ -z "${diskSize}" ]]; then
    #     echo "Error: diskSize should have a boolean value"
    #     exit 1
    # fi
    if [[ "${diskSize}" ]]; then
        echo "$diskSize"
        return
    fi
    echo "Error: diskSize somehow emtpy but this wasen't captured"
    exit 1
}

function getPhpVersion {
    local branchPhpVersion phpVersion

    branchPhpVersion=$(yq eval ".sites.${1}.${2}-php-version" "${3}")
    if [[ -n "${branchPhpVersion}" && "${branchPhpVersion}" != "null" ]]; then
        echo "${branchPhpVersion}"
        return
    fi

    phpVersion=$(yq eval ".sites.${1}.php-version" "${3}")
    if [[ -n "${phpVersion}" && "${phpVersion}" != "null" ]]; then
        echo "${phpVersion}"
        return
    fi

    echo "Error: Neither branchPhpVersion nor phpVersion is defined" >&2
    exit 1
}

function calculatePrimaryGoSubdomain {
    local hasGo=$(getGoRelease "${1}" "${2}")
    if [[ "${hasGo}" = "" ]]; then
        echo ""
        return
    fi
    local primaryDomain=$(getSitePrimaryDomain "${1}" "${2}")
    local goSubDomain="go.";
    # If primaryDomain uses www, then we want to put the go subdomain in there like this: www.go.restOfDomain.tld
    if [[ $primaryDomain == www* ]]; then
        echo "${primaryDomain/www./www.$goSubDomain}"
        return
    fi
    echo "$goSubDomain$primaryDomain";
    return
}

function calcutelateSecondaryGoSubDomains {
    local hasGo=$(getGoRelease "${1}" "${2}")
    if [[ "${hasGo}" = "" ]]; then
        echo ""
        return
    fi

    local secondaryDomains=$(getSiteSecondaryDomains "${1}" "${2}")
    if [[ "${secondaryDomains}" == "null" ]]; then
        echo ""
        return
    fi

    local secondaryGoSubDomains=""
    local goSubDomain="go."
    IFS=" "
    for secondaryDomain in ${secondaryDomains}; do
        # If secondaryDomain uses www, then we want to put the go subdomain in there like this: www.go.restOfDomain.tld
        if [[ $secondaryDomain == www* ]]; then
            secondaryGoSubDomains+="${secondaryDomain/www./www.$goSubDomain} "
        else
            secondaryGoSubDomains+="$goSubDomain$secondaryDomain ";
        fi
    done
    echo "${secondaryGoSubDomains}"
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

function adjustPersistentVolume {
    volumeName=$(kubectl get pvc -n "${1}"-"${2}" nginx --template={{.spec.volumeName}})
    az storage share update -n "$volumeName" --quota "${3}" --account-name stdpldplplat01585708af
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
primaryGoSubDomain=$(calculatePrimaryGoSubdomain "${SITE}" "${SITES_CONFIG}")
secondaryGoSubDomains=$(calcutelateSecondaryGoSubDomains "${SITE}" "${SITES_CONFIG}")
autogenerateRoutes=$(getSiteAutogenerateRoutes "${SITE}" "${SITES_CONFIG}")
releaseTag=$(getSiteDplCmsRelease "${SITE}" "${SITES_CONFIG}")
wmReleaseTag=$(getWebmasterDplCmsRelease "${SITE}" "${SITES_CONFIG}")
siteImageRepository=$(getSiteReleaseImageRepository "${SITE}" "${SITES_CONFIG}" || exit 1)
failOnErr $? "${siteImageRepository}"
siteReleaseImageName=$(getSiteReleaseImageName "${SITE}" "${SITES_CONFIG}")
failOnErr $? "${siteReleaseImageName}"
plan=$(getSitePlan "${SITE}" "${SITES_CONFIG}")
importTranslationsCron=$(getSiteImportTranslationsCron "${SITE}" "${SITES_CONFIG}")
goRelease=$(getGoRelease "${SITE}" "${SITES_CONFIG}")
diskSize=$(getDiskSize "${SITE}" "${SITES_CONFIG}")
phpVersionMain=$(getPhpVersion "${SITE}" "main" "${SITES_CONFIG}")
phpVersionModuletest=$(getPhpVersion "${SITE}" "moduletest" "${SITES_CONFIG}")
set -o errexit

# Synchronise the sites environment repository.
syncEnvRepo "${SITE}" "${releaseTag}" "${BRANCH}" "${siteImageRepository}" "${siteReleaseImageName}" "${importTranslationsCron}" "${autogenerateRoutes}" "${primaryDomain}" "${secondaryDomains}" "${diskSize}" "${phpVersionMain}" "${primaryGoSubDomain}" "${secondaryGoSubDomains}" "${goRelease}"
adjustPersistentVolume "${SITE}" "main" "${diskSize}"

if [ "${plan}" = "webmaster" ] && [ "${BRANCH}" = "main" ]; then
    syncEnvRepo "${SITE}" "${wmReleaseTag}" "moduletest" "${siteImageRepository}" "${siteReleaseImageName}" "${importTranslationsCron}" "${autogenerateRoutes}" "${primaryDomain}" "${secondaryDomains}" "${diskSize}" "${phpVersionModuletest}"
    adjustPersistentVolume "${SITE}" "moduletest" "${diskSize}"
fi
