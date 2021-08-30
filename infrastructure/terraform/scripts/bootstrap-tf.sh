#!/usr/bin/env bash
#
# This scripts bootstraps the terraform setup.
#
# It should only be nessecary to run this script once in the lifetime of the
# a Terraform setup. A single setup manages multiple environments and stores
# the state for the individual envrionments in seperate Terraform states.
#
# The script sets up a resource-group and places a storage-account
# and an keyvault into this group all to be used for managing Terraforms own
# state.
#
# The script requires a name for the terraform setup, a id for the subscription
# that should be used and optionally an increment in case name the script uses
# for the keyvault or storage account are already in use.
#
set -euo pipefail

IFS=$'\n\t'

if [[ $# -lt 2 ]] ; then
    echo "Syntax: $0 <terraform setup name> <subscription id> [increment]"
    exit 1
fi

# The Subscription we'll use for everything
SUBSCRIPTION_ID="${2}"

INC="${3:-001}"
TF_SETUP_NAME=$1

# Inspired by https://blog.jcorioland.io/archives/2019/09/09/terraform-microsoft-azure-remote-state-management.html
LOCATION="westeurope"
# The resource-group we'll place the setup resources into.
RESOURCE_GROUP="rg-tfstate-${TF_SETUP_NAME}"

# Base names of the resources.
TF_STATE_STORAGE_ACCOUNT_NAME="stdpltfstate${TF_SETUP_NAME}${INC}"
TF_STATE_CONTAINER_NAME="state"
KEYVAULT_NAME="kv-dpltfstate${TF_SETUP_NAME}${INC}"

# Create the resource group for holding Terraform resources.
echo "Creating $RESOURCE_GROUP resource group..."
az group create -n "${RESOURCE_GROUP}" -l $LOCATION --subscription "${SUBSCRIPTION_ID}"

echo "Resource group $RESOURCE_GROUP created."

# Create the storage account that will hold the Terraform state.
echo "Creating $TF_STATE_STORAGE_ACCOUNT_NAME storage account..."
az storage account create --subscription "${SUBSCRIPTION_ID}" -g "${RESOURCE_GROUP}" -l "${LOCATION}" \
  --name $TF_STATE_STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

echo "Storage account $TF_STATE_STORAGE_ACCOUNT_NAME created."

# Retrieve the storage account key that Terraform will use to access its state.
echo "Retrieving storage account key..."
ACCOUNT_KEY=$(az storage account keys list --subscription "${SUBSCRIPTION_ID}" --resource-group "${RESOURCE_GROUP}" --account-name "${TF_STATE_STORAGE_ACCOUNT_NAME}" --query [0].value -o tsv)

echo "Storage account key retrieved."

# Create a storage container (for the Terraform State)
echo "Creating $TF_STATE_CONTAINER_NAME storage container..."
az storage container create --subscription "${SUBSCRIPTION_ID}" --name $TF_STATE_CONTAINER_NAME --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "Storage container $TF_STATE_CONTAINER_NAME created."

# Create an Azure KeyVault to hold the storage-account key.
echo "Creating $KEYVAULT_NAME key vault..."
az keyvault create --subscription "${SUBSCRIPTION_ID}" -g "${RESOURCE_GROUP}" -l "${LOCATION}" --name "${KEYVAULT_NAME}"

echo "Key vault ${KEYVAULT_NAME} created."

# Store the Storage Account Key into KeyVault
echo "Store storage access key into key vault secret..."
az keyvault secret set --subscription "${SUBSCRIPTION_ID}" --name tfstate-storage-key --value "${ACCOUNT_KEY}" --vault-name $KEYVAULT_NAME

echo "Key vault secret created."

# Display information to be used for configuring backends for the individual
# Terraform-managed environments.
echo "Azure Storage Account and KeyVault have been created."
echo "Create the following DPL shell profile in the root of the terraform directory."
echo "DPL shell can subsequently be started in the terraform directory and used to run Terraform."
echo "--- start terraform/.dplsh.profile ---"
cat <<EOT
echo "Unlocking terraform state...."
export ARM_ACCESS_KEY=\$(az keyvault secret show --subscription "${SUBSCRIPTION_ID}" --name tfstate-storage-key --vault-name $KEYVAULT_NAME --query value -o tsv)
EOT
echo "--- end terraform/.dplsh.profile  ---"
echo ""
echo "Use the following backend configuration for new module that should have"
echo " its own Terraform state. Replace <env> with the name of the environment"
echo "--- start terraform/environments/<env>/backend.tf  ---"
cat <<EOT
terraform {
  backend "azurerm" {
    storage_account_name = "$TF_STATE_STORAGE_ACCOUNT_NAME"
    container_name       = "$TF_STATE_CONTAINER_NAME"
    key                  = "<env>.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "${SUBSCRIPTION_ID}"
}
EOT
echo "--- end terraform/environments/<env>/backend.tf  ---"

echo ""
echo "Then cd to the terraform directory, launch dplsh, cd to an environment module and perform a \"terraform init\""

