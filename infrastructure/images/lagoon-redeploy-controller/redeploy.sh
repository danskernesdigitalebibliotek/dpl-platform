#!/bin/sh

# if [ -f /config/.lagoon.yml ]; then
#   cp /config/.lagoon.yml /root/.lagoon.yml
# fi

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

redeployDeployments() {
  date '+%H:%M'
  FAILED_PRODUCTION_DEPLOYMENTS=$(/lagoon raw --raw "query allProjects {
    allProjects {
    name
      environments(type: PRODUCTION) {
        name
        deployments(limit: 1) {
          status
          created
        }
      }
    }
  }" | jq -r '.allProjects[] | .name as $name | .environments[].deployments[] | select(.status == "failed") | ($name)')

  if [ -n "$FAILED_PRODUCTION_DEPLOYMENTS" ]; then
    echo "Redeploying failed production environments"

    for deployment in $FAILED_PRODUCTION_DEPLOYMENTS; do
      if [[ $deployment =~ "dpl-cms" ]]; then
        continue
      fi
      if [[ $deployment =~ "dpl-bnf" ]]; then
        continue
      fi
      echo "$deployment: deploying"
      /lagoon deploy latest -p "$deployment" -e "main" --force
    done
  else
    echo "No failed production deployments to redeploy"
  fi

  echo "Now checking for failed development site deployments"
  FAILED_DEVELOPMENT_DEPLOYMENTS=$(/lagoon raw --raw "query allProjects {
    allProjects {
    name
      environments(type: DEVELOPMENT) {
        name
        deployments(limit: 1) {
          status
          created
        }
      }
    }
  }" | jq -r '.allProjects[] | .name as $name | .environments[].deployments[] | select(.status == "failed") | ($name)')

  if [ -n "$FAILED_DEVELOPMENT_DEPLOYMENTS" ]; then
    echo "Redeploying failed development environments"

    for deployment in $FAILED_DEVELOPMENT_DEPLOYMENTS; do
      if [[ $deployment =~ "dpl-cms" ]]; then
        continue
      fi
      if [[ $deployment =~ "dpl-bnf" ]]; then
        continue
      fi
      echo "$deployment: deploying"
      /lagoon deploy latest -p "$deployment" -e "moduletest" --force
    done
  else
    echo "No failed development deployments to redeploy"
  fi
}

echo "start redeploying"

while true
do
  redeployDeployments
  echo "waiting for 5 minutes before checking for failed deployments again"
  sleep 300
done
