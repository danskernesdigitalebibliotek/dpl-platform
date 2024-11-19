#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail
IFS=$'\n\t'

# Find a file in current or parrent directories.
find-up () {
  path=$(pwd)
  while [[ "$path" != "" && ! -e "$path/$1" ]]; do
    path=${path%/*}
  done

  echo "${path}"
}

PROFILE_FILE=
CONTAINER_IMAGE="${DPLSH_IMAGE:-ghcr.io/danskernesdigitalebibliotek/dpl-platform/dplsh:latest}"
CHDIR=
SHELL_ROOT="${PWD}"

# both $1 and $2 are absolute paths beginning with /
# returns relative path to $2 from $1
# From http://stackoverflow.com/a/12498485
function relativePath {
  local source=$1
  local target=$2

  local commonPart=$source
  local result=""

  while [[ "${target#"$commonPart"}" == "${target}" ]]; do
    # no match, means that candidate common part is not correct
    # go up one level (reduce common part)
    commonPart=$(dirname "${commonPart}")
    # and record that we went back, with correct / handling
    if [[ -z $result ]]; then
      result=".."
    else
      result="../$result"
    fi
  done

  if [[ $commonPart == "/" ]]; then
    # special case for root (no common path)
    result="$result/"
  fi

  # since we now have identified the common part,
  # compute the non-common part
  local forwardPart="${target#"$commonPart"}"

  # and now stick all parts together
  if [[ -n $result ]] && [[ -n $forwardPart ]]; then
    result="$result$forwardPart"
  elif [[ -n $forwardPart ]]; then
    # extra slash removal
    result="${forwardPart:1}"
  fi

  echo "${result}"
}

# Use standin for realpath if we don't have it.
if ! command -v realpath > /dev/null 2>&1; then
    # realpath is not available on OSX unless you install the `coreutils` brew
    realpath() { _realpath "$@"; }
fi

if [[ $# -gt 0 && $1 == "--update" ]] ; then
  docker pull "${CONTAINER_IMAGE}"
  echo "update done"
  exit 0
fi

# Fix docker socket
if [[ $# -gt 0 && $1 == "--fix-docker" ]] ; then

    # Check that we have a socket
    if [[ ! -S /var/run/docker.sock ]]; then
        echo "Could not find /var/run/docker.sock"
        exit 1
    fi
    # We could do more, but really, this is a quite specific and advanced fix so
    # lets just head on.

    # On Mac, this change only persists inside docker and won't leak back into
    # the host. Will need to be reapplied after a restart of docker though.
    # On Linux, this change persists on the host, and means that docker.sock is
    # no longer owned by root.
    echo "* Changing ownership of /var/run/docker.sock inside docker to dplsh (uid 1000)"
    docker run  \
    --rm \
    --mount "type=bind,src=/var/run/docker.sock,target=/var/run/docker.sock" \
    --user root \
    "${CONTAINER_IMAGE}" chown dplsh /var/run/docker.sock

    # Strip away the arg and continue.
    shift
fi

# Attempt to load requested profile, fail if impossible.
if [[ $# -gt 0 && ( $1 == "-p" || $1 == "--profile" ) ]] ; then
    shift 1
    requested_profile=$1
    requested_profile_FILE=".dplsh.profile.${requested_profile}"
    # We where requested to use a profile, attempt to find it
    PROFILE_ROOT=$(find-up "${requested_profile_FILE}")

    if [[ -z "${PROFILE_ROOT}" ]] ; then
        echo "Could not launch with requested profile '${requested_profile}' - unable to find ${requested_profile_FILE} in current or parent directories."
        exit 1
    fi
    PROFILE_FILE="${requested_profile_FILE}"
    # Pop off the environment argument
    shift 1
else
    # Just attempt to find ".dplsh.profile" and queue it up for load if it exists
    PROFILE_FILE=".dplsh.profile"
    PROFILE_ROOT=$(find-up "${PROFILE_FILE}")
fi

ADDITIONAL_ARGS=()
if [[ -n "${PROFILE_ROOT}" ]]; then
    ADDITIONAL_ARGS+=(-v "${PROFILE_ROOT}/${PROFILE_FILE}:/home/dplsh/.dplsh.profile")
    CHDIR=$(relativePath "${PROFILE_ROOT}" "$PWD")
    SHELL_ROOT="${PROFILE_ROOT}"
fi

if [[ -S /var/run/docker.sock ]]; then
    ADDITIONAL_ARGS+=(-v "/var/run/docker.sock:/var/run/docker.sock")
fi

# Get docker credentials (username, password, repository)
# returned as an array.
function export-docker-creds() {
  local docker_conf=${HOME}/.docker/config.json
  local docker_auth=
  # Use the name passed as argument as return variable
  local -n return_map=$1

  # Name of the way creds are stored
  local docker_credstore=
  # See if we have a docker-config.
  if [[ -f ${docker_conf} ]]; then
    local docker_credstore
    docker_credstore=$(jq -r '.credsStore // empty' < "${docker_conf}")
    local creds_key
    creds_key=$(jq -r '.auths // [] | keys[]' < "${docker_conf}")
    # Split into array
    local creds_array
    declare -a creds_array
    IFS=$'\n' mapfile -t creds_array <<< "$creds_key"

    # Loop through all creds.
    local cred_count=0
    for (( i=0; i<${#creds_array[@]}; i++ )); do
      cred_key=${creds_array[$i]}

      # To keep the number of creds lower we only import github and acr creds
      if [[ $cred_key != *".github.com"* && $cred_key != *"azurecr.io"* ]]; then
        continue
      fi

      local docker_user docker_password docker_registry
      # See if the docker-config uses a backing credential-store that holds the
      # actual credentials.
      if [[ -n ${docker_credstore} && "${docker_credstore}" != "null" ]]; then
        # We have a credential store - use it to get the credentials and extract
        # the value from the returned json object.
        local creds
        creds=$(echo "${cred_key}" | "docker-credential-${docker_credstore}" get)
        docker_user=$(echo "${creds}" | jq -r '.Username' | base64)
        docker_password=$(echo "${creds}" | jq -r '.Secret' | base64)
        docker_registry=$(echo "${creds}" | jq -r '.ServerURL' | base64)
      else
        # No credential store, so the password should be availably directly in the
        # config.
        local docker_auth
        docker_auth=$(jq -r ".auths[\"$cred_key\"].auth" < "${docker_conf}")
        # Split out the credentials if found.
        IFS=':' read -ra auth <<< "$(echo "${docker_auth}" | base64 -d)"
        docker_user=$(echo "${auth[0]}" | base64)
        docker_password=$(echo "${auth[1]}" | base64)
        docker_registry=$(echo "${cred_key}" | base64)
      fi

      # Add as environment variables for the shell.
      if [[ -n "${docker_user}" && "${docker_user}" != "null" && -n "${docker_password}" && "${docker_password}" != "null" ]]; then
        return_map["DOCKER_USER_$cred_count"]="${docker_user}"
        return_map["DOCKER_PASSWORD_$cred_count"]="${docker_password}"
        # shellcheck disable=SC2034 # passed as reference so we know it to be used
        return_map["DOCKER_REGISTRY_$cred_count"]="${docker_registry}"

        # Increment for the next cred.
        cred_count=$((cred_count+1))
      fi
    done
  fi
}

# Pass an assosciative array to export-docker-creds and export the result as
# environment variables inside the container.
declare -A docker_creds
export-docker-creds docker_creds
for key in "${!docker_creds[@]}"; do
  ADDITIONAL_ARGS+=(-e "${key}=${docker_creds[$key]}")
done

# We run in interactive mode unless if we're in DPLSH_NON_INTERACTIVE.
if [[ -z "${DPLSH_NON_INTERACTIVE:-}" ]]; then
  ADDITIONAL_ARGS+=(-i)
fi

# Only mount in ${HOME}/.gitconfig if it exists. Otherwise docker will
# create an empty, root owned {HOME}/.gitconfig which will make git
# very unhappy.
if [[ -f "${HOME}/.gitconfig" ]] ; then
    GITCONFIG+=(-v "${HOME}/.gitconfig:/opt/.gitconfig-host:ro")
fi

docker run --hostname=dplsh \
    --rm \
    "${ADDITIONAL_ARGS[@]}" \
    -t \
    -e "HOST_UID=$(id -u)" \
    -v "${HOME}/.azure:/opt/.azure-host:ro" \
    "${GITCONFIG[@]}" \
    -v "${HOME}/.ssh:/opt/.ssh-host:ro" \
    -v "${SHELL_ROOT}:/home/dplsh/host_mount" \
    -w "/home/dplsh/host_mount/${CHDIR}" \
    "${CONTAINER_IMAGE}" "$@"
