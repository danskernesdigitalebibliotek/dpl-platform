#!/usr/bin/env bash
#
# Check all nginx php containers for I/O errors and restart the nginx deployment
# if found.
set -eu

# Array to hold namespaces with errors
error_namespaces=()

# Function to check if kubectl is authenticated and connected to a cluster
check_kubectl_authentication() {
    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo "Error: kubectl is not authenticated or no Kubernetes cluster is available."
        exit 1
    fi
}

# Function to check pods and restart the deployment if errors are found
check_and_restart() {
    local namespace=$1
    local pod=$2

    # Check for "I/O error" using kubectl exec
    if kubectl exec -n "$namespace" "$pod" -c php -- df -h 2>&1 | grep -q "I/O error"; then
        echo "$namespace, $pod: ERROR"
        echo "Running rollout restart for nginx deployment in namespace $namespace..."
        kubectl -n "$namespace" rollout restart deploy/nginx

        # Add namespace to the error list if not already in the array
        if [[ ! " ${error_namespaces[*]} " =~ ${namespace} ]]; then
            error_namespaces+=("$namespace")
        fi
    else
        echo "$namespace, $pod: OK"
    fi
}

# Ensure kubectl is authenticated
check_kubectl_authentication

# Get the list of relevant pods across all namespaces
while IFS= read -r line; do
    namespace=$(echo "$line" | awk '{print $1}')
    pod=$(echo "$line" | awk '{print $2}')
    check_and_restart "$namespace" "$pod"
done < <(kubectl get pods --all-namespaces -l lagoon.sh/service=nginx -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name --no-headers)

# Output summary of namespaces that had errors
if [ ${#error_namespaces[@]} -ne 0 ]; then
    echo -e "\nDisse sites blev fixet:"
    for ns in "${error_namespaces[@]}"; do
        # Remove "-main" from the namespace name if it exists
        cleaned_ns=${ns//-main/}
        echo "- $cleaned_ns"
    done
    echo -e "\n"
else
    echo "No errors found in any namespace."
fi
