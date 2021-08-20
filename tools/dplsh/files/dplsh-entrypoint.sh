#!/usr/bin/env bash
set -euo pipefail

# Output a script that itself will start dplsh via docker.
if [[ $# -eq 1 && $1 == "bootstrap" ]] ; then
    cat /opt/dplsh/dplsh.sh
    exit 0
fi

# Copy the host' azure state into the current shell.
# By working off of a copy, we can feel free to eg. deauth without affecting
# the host.
if [[ -d /home/dplsh/.azure-host ]] ; then
    mkdir -p /home/dplsh/.azure
    rsync -a --exclude=logs --exclude=commands --exclude=telemetry /home/dplsh/.azure-host/ /home/dplsh/.azure/
fi

PATH=${PATH}:${HOME}/bin
export PATH

# See if dplsh was passed an argument.
if [[ $# -gt 0 ]] ; then
    # We got aguments, eg the user invoked
    # dplsh ls -l
    # fire up a login-shell and execute the command
    bash -l -c "${*}"
else
    # No argument, just start a login shell.
    bash -l
fi

