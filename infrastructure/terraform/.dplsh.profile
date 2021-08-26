echo "Unlocking terraform state...."
export ARM_ACCESS_KEY=$(az keyvault secret show --subscription "8ac8a259-5bb3-4799-bd1e-455145b12550" --name tfstate-storage-key --vault-name kv-dpltfstatealpha001 --query value -o tsv)
echo "Now cd to an environment folder to continue your work..."
