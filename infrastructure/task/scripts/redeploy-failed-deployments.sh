#!/usr/bin/env bash
#
# 80% of failed deployments is fixed by redeploying the failed deployment.
# This script will help make that easier to do.

echo "Will now start to redeploying failed deployments"
echo "Finding failed main environments"

FAILED_PRODUCTION_DEPLOYMENTS=$(lagoon raw --raw "query allProjects {
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

echo "Redeploying failed production environments"

for deployment in $FAILED_PRODUCTION_DEPLOYMENTS; do
  if [[ $deployment =~ "dpl-cms" ]]; then
    continue
  fi
  if [[ $deployment =~ "dpl-bnf" ]]; then
    continue
  fi
  echo "$deployment: deploying"
  lagoon deploy latest -p "$deployment" -e "main" --force
done

echo "Finding failed development environments"

FAILED_DEVELOPMENT_DEPLOYMENTS=$(lagoon raw --raw "query allProjects {
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

echo "Redeploying failed moduletest environments"

for deployment in $FAILED_DEVELOPMENT_DEPLOYMENTS; do
  if [[ $deployment =~ "dpl-cms" ]]; then
    continue
  fi
  if [[ $deployment =~ "dpl-bnf" ]]; then
    continue
  fi
  echo "$deployment: deploying"
  lagoon deploy latest -p "$deployment" -e "moduletest" --force
done

echo "Done - all failed deployments has now be redeployed"
