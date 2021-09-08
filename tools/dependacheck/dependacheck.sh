#!/bin/bash

SKIPLIST=""

while getopts ":s:h" opt; do
    case ${opt} in
        s )
            SKIPLIST=$OPTARG
            ;;
        h )
            echo "Usage: dependacheck [OPTION]..."
            echo "Finds Dockerfiles and checks that they're mentioned in depentabot config."
            echo
            echo "Options:"
            echo "  -s    Comma separated list of paths to skip"
            echo "  -h    This help text"
            exit
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Invalid Option: -$OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done

# Use sed to strip the leading dot.
DOCKER_FILES=$(find . -name Dockerfile | sed -e 's/^\.//')

EXIT_CODE=0

echo "Checking that depentabot it configured with all Dockerfiles"

for FILE in $DOCKER_FILES; do
    DIR=$(dirname "${FILE}")
    echo -n "${DIR}"
    if [[ ",$SKIPLIST," = *,$DIR,* ]]; then
        echo " [SKIPPED]"
        continue
    fi
    if grep -q "directory: \"$DIR\"" .github/dependabot.yml; then
        echo " [OK]"
    else
        echo " [Missing Dependabot configuration for Dockerfile]"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
