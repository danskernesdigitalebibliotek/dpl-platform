#!/usr/bin/env bash
#
#
set -euo pipefail

IFS=$'\n\t'

if [[ $# -lt 3 ]] ; then
    echo "Syntax: $0 <terraform setup name> <subscription id> <api-key> [increment]"
    exit 1
fi

TF_SETUP_NAME=$1
SUBSCRIPTION_ID="${2}"
API_KEY="${3}"
INC="${4:-001}"
KEYVAULT_NAME="kv-dpltfstate${TF_SETUP_NAME}${INC}"

echo "Adding the key to the ${KEYVAULT_NAME} keyvault..."
az keyvault secret set --subscription "${SUBSCRIPTION_ID}" --name dnsimple-api-key --value "${API_KEY}" --vault-name "${KEYVAULT_NAME}"
