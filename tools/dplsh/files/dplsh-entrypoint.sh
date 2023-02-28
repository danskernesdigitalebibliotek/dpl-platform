#!/usr/bin/env bash
#
# The entrypoint is the first thing that runs when the container is started by
# dplsh.sh. It is responsible for doing the last minute setup that could not
# be done in the Dockerfile, and then start the dplsh users shell.
#
# Be aware that the entrypoint runs as root, but ends with a su to the dplsh
# user to ensure the user ends in an unprivileged shell.
#
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
    rsync \
      --archive \
      --chown dplsh:dplsh \
      --exclude=logs \
      --exclude=commands \
      --exclude=telemetry \
      --exclude=.git \
      /home/dplsh/.azure-host/ /home/dplsh/.azure/
fi

if [[ -f /home/dplsh/.gitconfig-host ]] ; then
    cp /home/dplsh/.gitconfig-host /home/dplsh/.gitconfig
    chown dplsh /home/dplsh/.gitconfig
fi

if [[ -d /home/dplsh/.ssh-host ]] ; then
    mkdir -p /home/dplsh/.ssh
    rsync --archive \
      --chown dplsh:dplsh \
      --exclude=commands \
      --exclude=.git \
      /home/dplsh/.ssh-host/ /home/dplsh/.ssh/
fi

PATH=${PATH}:${HOME}/bin
export PATH

# Start the unprivileged shell, passing on any additional arguments we got.
if [[ $# -gt 0 ]] ; then
    # We got aguments, eg the user invoked
    # dplsh ls -l
    # fire up a login-shell and execute the command
    exec su dplsh -c "bash -l -c '${*}'"
else
    # No argument, just start a login shell.
    exec su dplsh -c "bash -l"
fi
