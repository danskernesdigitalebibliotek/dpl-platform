#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/deploy-shared.source"

function print_usage {
    # Start with a more specific error-message if we're passed the name of a
    # variable that was missing.
    if [[ -n "${1}" ]]; then
        echo "Could not find the variable ${1}"
    fi
    echo
    echo "Set the following environment variables before running the script."
    echo "  RELEASE_TAG: the tag of the source-release you want to deploy"
    echo "  SITE:        the name of the site."
    echo
    echo "The following variables are optional"
    echo "  BRANCH: The branch you want to deploy, defaults to main."
    echo "  DIFF:   If set to 1 the script will go Go through the motions, but."
    echo "          only display the diff from the current repository."
    echo "  FORCE:  Deploy even if there is no diff in which case an empty"
    echo "          commit will be pushed."

    exit 1
}

if [[ -z "${RELEASE_TAG:-}" ]]; then
    print_usage "RELEASE_TAG"
fi

if [[ -z "${SITE:-}" ]]; then
    print_usage "SITE"
fi

BRANCH=${BRANCH:-main}

# Deploy site
deploy "${SITE}" "${RELEASE_TAG}" "${BRANCH}"

