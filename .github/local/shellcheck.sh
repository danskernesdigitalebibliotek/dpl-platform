#!/usr/bin/env bash
#
# Runs a check of all shell-scripts in the repository
#
# We pin the version of shellcheck to match that of the latest github action
# runner. This may mean we drift out of sync at some point, but as the action
# will ultimately use whats shipped with the runner, anyone using this script
# should be automatically motivated to keep it in sync as the actions start
# reporting other errors than the script.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Go to the root.
cd "${SCRIPT_DIR}/../.."

SHELLCHECK_VERSION=v0.7.0
# Consult https://github.com/actions/virtual-environments for the current version
# of shellcheck being used.
# We use find to pick out the files we want processed, clean up the result a
# bit so that the path to the file is a clean as possible, and then run shellcheck.
docker run \
  --mount "type=bind,src=$(pwd),dst=/mnt,readonly" \
  "koalaman/shellcheck-alpine:${SHELLCHECK_VERSION}" \
  sh -c "cd /mnt && find . -name '*.sh' ! -path '*/vendor/*' -not -path '*/.terraform/*' -not -path './.git/*'| cut -c3- | xargs shellcheck --external-sources -P SCRIPTDIR"
