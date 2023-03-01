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

if [[ -f /opt/.gitconfig-host ]] ; then
    cp /opt/.gitconfig-host /home/dplsh/.gitconfig
fi

# Copy the host' azure state into the current shell.
# By working off of a copy, we can feel free to eg. deauth without affecting
# the host.
if [[ -d /opt/.azure-host ]] ; then
    mkdir -p /home/dplsh/.azure
    rsync \
      --archive \
      --exclude=logs \
      --exclude=commands \
      --exclude=telemetry \
      --exclude=.git \
      /opt/.azure-host/ /home/dplsh/.azure/
fi

if [[ -d /opt/.ssh-host ]] ; then
    mkdir -p /home/dplsh/.ssh
    rsync --archive \
      --exclude=commands \
      --exclude=.git \
      /opt/.ssh-host/ /home/dplsh/.ssh/
fi

# # Change uid of the dplsh user so that it matches that of the host.
if [[ -n "${HOST_UID:-}" ]] ; then
    usermod -u "${HOST_UID}" dplsh
fi
if [[ -n "${HOST_GID:-}" ]] ; then
    usermod -g "${HOST_GID}" dplsh
fi

# Change the ownership of the dplsh user's home directory to the new uid/gid but
# exclude the directories we've mounted from the host as they already have the
# ownership we want.
find /home/dplsh \
  -mindepth 1 \
  -maxdepth 1 \
  ! -name host_mount \
  -exec \
    chown -R "${HOST_UID}:${HOST_GID}" {} \;

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
