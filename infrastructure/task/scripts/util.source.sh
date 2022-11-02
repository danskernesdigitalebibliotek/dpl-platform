#!/usr/bin/env bash
# Various utility functions used by the provision-* scripts

# Verify that a platform environment directory exists and contains a versions.env
function getEnvDir() {
  local env="${DPLPLAT_ENV:-}"
  local env_dir
  env_dir=$(realpath "${SCRIPT_DIR}/../../environments/${env}")
  if [[ ! -d "${env_dir}" ]]; then
    echo "${env_dir} does not exist"
    exit 1
  fi

  echo "${env_dir}"
}

# Adds the helm repo (if it does not exist) and refreshes our state
function setupHelmRepo() {
  local alias=$1
  local url=$2
  # See if we can find the repo in the list of repos, if not add it
  if ! helm repo list | grep "^${alias}\b"; then
    helm repo add "${alias}" "${url}"
    helm repo update "${alias}"
  fi
}

# Returns the path to the versions.env for the environment.
# Errors out if the file does not exist.
function getVersionsEnv() {
    local versions_env
    versions_env="$(getConfigurationDir)/versions.env"
    if [[ ! -f "${versions_env}" ]]; then
      echo "${versions_env} does not exist"
    exit 1
  fi

  echo "${versions_env}"
}

# Gets the path to an environments configuration directory.
function getConfigurationDir() {
  local configuration_dir
  configuration_dir="$(getEnvDir)/configuration"
  echo "${configuration_dir}"
}


# Determines whether we're currently in DIFF mode.
function isDiffing() {
  test -n "${DIFF:-}"
}

# Returns the first argument if we're diffing, the second if not.
function ifDiffTernary() {
  if isDiffing; then
    echo "${1}"
  else
    echo "${2:-}"
  fi
}

# Handles the different exitcodes kubectl will produce depending on whether we
# are diffing (exitcode > 1 means error) or applying (exitcode > 0 means error).
function handleApplyDiffExit() {
  local exitcode=$1
  if test "${exitcode}" -eq 0; then
    return
  fi

  if isDiffing && test "${exitcode}" -lt 1; then
    echo "Error during kubectl diff detected"
    exit 1
  fi

  if ! isDiffing && test "${exitcode}" -lt 0; then
    echo "Error during kubectl apply detected"
    exit 1
  fi
}

# Verifies that an environment-variable exists.
function verifyVariable() {
  local variable=$1
  if [[ -z "${!variable:-}" ]]; then
    echo "Environment variable $variable is empty or missing"
    exit 1
  fi;
}
