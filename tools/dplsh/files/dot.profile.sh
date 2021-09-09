#!/usr/bin/env bash
# shellcheck source=/dev/null # no way for shellcheck to verify.
source <(kubectl completion bash)
SHELL_INCLUDE="${HOME}/.dplsh.profile"

# Add Task completion
_task_completion()
{
  local scripts;
  local curr_arg;

  # Remove colon from word breaks
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

  scripts=$(task -l | sed '1d' | awk '{ print $2 }' | sed 's/:$//');

  curr_arg="${COMP_WORDS[COMP_CWORD]:-"."}"

  # Do not accept more than 1 argument
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  fi

  # shellcheck disable=SC2216 # shellcheck does not like us piping to grep
  COMPREPLY=("$(compgen -c | echo "${scripts}" | grep -- "${curr_arg}")");
}

complete -F _task_completion task

function docker-login() {
    local user
    local pass
    local registry
    # Split auth string into username and token and log in to registry
    user=$(echo "${1}" | base64 -d)
    pass="$(echo "${2}" | base64 -d)"
    registry=$(echo "${3}" | base64 -d)
    echo "${pass}" | docker login "${registry}" -u "${user}" --password-stdin 1> /dev/null 2> /dev/null
}

# See if we're passed any docker logins.
for (( i=0 ; ; i++ )); do
    docker_user="DOCKER_USER_${i:-}"
    docker_pass="DOCKER_PASSWORD_${i:-}"
    docker_registry="DOCKER_REGISTRY_${i:-}"

    if [[ -z "${!docker_user}" ]] ; then
        break
    fi
    docker-login "${!docker_user}" "${!docker_pass}" "${!docker_registry}"
done

if [[ -f $SHELL_INCLUDE ]]; then
    source "${SHELL_INCLUDE}"
fi;
