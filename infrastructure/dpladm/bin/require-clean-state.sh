#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail
echo "testing state"
# Should be main to run
# current_branch=$(git branch --show-current)
# if [ 'current_branch' != 'canary' ]; then
#   echo 'Can't deploy if not on main branch'
#   exit 1
# fi
# if [! git diff-index --quiet HEAD --]; then
#   echo 'Can't deploy if there's changes on the branch'
#   exit 1
# fi
exit 0
