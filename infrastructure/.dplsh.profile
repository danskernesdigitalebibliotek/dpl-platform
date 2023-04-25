echo "** Danish Public Libraries Platform Shell **"
echo "... Fetching Storage Account key to unlock terraform state"
AZURE_KEYVAULT_NAME=kv-dpltfstatealpha001
AZURE_SUBSCRIPTION=8ac8a259-5bb3-4799-bd1e-455145b12550
export ARM_ACCESS_KEY=$(\
  az keyvault secret show \
    --subscription "${AZURE_SUBSCRIPTION}" \
    --name tfstate-storage-key \
    --vault-name ${AZURE_KEYVAULT_NAME} \
    --query value \
    -o tsv\
)
if [[ -z "${ARM_ACCESS_KEY}" ]]; then
    echo "ERROR: Could not retrieve the tfstate-storage-key secret from keyvault."
    echo "Verify your current az login session has enough permissions to do so."
    echo "Keyvault name: ${AZURE_KEYVAULT_NAME}, subscription: ${AZURE_SUBSCRIPTION}"
    exit 1
fi
export DNSIMPLE_TOKEN=$(\
  az keyvault secret show \
    --subscription "${AZURE_SUBSCRIPTION}" \
    --name dnsimple-api-key \
    --vault-name ${AZURE_KEYVAULT_NAME} \
    --query value -o tsv\
)
if [[ -z "${DNSIMPLE_TOKEN}" ]]; then
    echo "ERROR: Could not retrieve the dnsimple-api-key secret from keyvault."
    echo "Verify your current az login session has enough permissions to do so."
    echo
    echo "Keyvault name: ${AZURE_KEYVAULT_NAME}, subscription: ${AZURE_SUBSCRIPTION}"
    exit 1
fi
export DNSIMPLE_ACCOUNT="61014"

export DPLPLAT_ENV="dplplat01"
echo
echo "Environment is assumed to be 'dplplat01'"
echo "If you want to operate another environment, run 'export DPLPLAT_ENV=<environment>'"
echo "Consult https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/docs/platform-environments.md"
echo
echo "Now run "task" to continue your work."
echo
