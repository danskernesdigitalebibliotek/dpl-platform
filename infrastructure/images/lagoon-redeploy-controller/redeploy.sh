#!/bin/sh

# chmod 600 /root/.ssh/id_rsa

# # Install jq
# wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
# chmod +x ./jq
# cp jq /usr/bin

# Add lagoon config
/lagoon config add \
  --graphql https://api.lagoon.dplplat01.dpl.reload.dk/graphql \
  --force \
  --ui https://ui.lagoon.dplplat01.dpl.reload.dk \
  --hostname 20.238.147.183 \
  --port 22 \
  --lagoon dplplat01

# Set dplplat01 as default config
/lagoon config default --lagoon dplplat01

getFailedDeployments() {
  local environment_type=$1
  /lagoon raw --raw "query allProjects {
    allProjects {
      name
      environments(type: $environment_type) {
        name
        deployments(limit: 1) {
          status
          created
        }
      }
    }
  }" | jq -r '.allProjects[] | .name as $name | .environments[].deployments[] | select(.status == "failed") | ($name)'
}

declare -A redeploy_attempts_array

redeployDeployments() {
  local environment_type=$1
  local environment_name=$2
  local allowed_attempts=$3
  local failed_deployments=$(getFailedDeployments $environment_type)

  if [ -n "$failed_deployments" ]; then
    echo "Redeploying failed $environment_type environments"

    for deployment in $failed_deployments; do
      if [[ $deployment =~ "dpl-cms" || $deployment =~ "dpl-bnf" ]]; then
        continue
      fi
      # logic for finding out wether to redeploy or not - take into account map might not have value yet
      echo "$deployment-$environment_name: deploying"
      /lagoon deploy latest -p "$deployment" -e "$environment_name" --force
      redeploy_attempts_array["$deployment-$environment_name"]+=1
    done
  else
    echo "No failed $environment_type deployments to redeploy"
  fi
}

echo "start redeploying"

while true
do
  redeployDeployments "PRODUCTION" "main" 6
  redeployDeployments "DEVELOPMENT" "moduletest" 3
  echo "waiting for 5 minutes before checking for failed deployments again"
  sleep 300
done
