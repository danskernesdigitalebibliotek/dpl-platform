#!/usr/bin/env bash
#
# Get varoius UI passwords.
# Meant as a helper script for manually logging into user interfaces.
#
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=./util.source.sh
source "${SCRIPT_DIR}/util.source.sh"

# These variables is taken from the environment.
verifyVariable "UI_NAME"

# Get password if possible.
case $UI_NAME in

  grafana)
    NAMESPACE="grafana"
    SECRET="grafana"
    JSON_PATH="{.data.admin-password}"
    ;;
  harbor)
    NAMESPACE="harbor"
    SECRET="harbor-harbor-core"
    JSON_PATH="{.data.HARBOR_ADMIN_PASSWORD}"
    ;;
  keycloak)
    NAMESPACE="lagoon-core"
    SECRET="lagoon-core-keycloak"
    JSON_PATH="{.data.KEYCLOAK_ADMIN_PASSWORD}"
    ;;
  lagoon)
    NAMESPACE="lagoon-core"
    SECRET="lagoon-core-keycloak"
    JSON_PATH="{.data.KEYCLOAK_LAGOON_ADMIN_PASSWORD}"
    ;;
  *)
    echo "The UI name ${UI_NAME} is unknown."
    exit 1;
    ;;
esac

# Output password.
kubectl get secrets -n $NAMESPACE $SECRET -o jsonpath=$JSON_PATH | base64 -d; echo
