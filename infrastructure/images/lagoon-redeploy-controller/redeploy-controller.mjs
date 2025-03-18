#!/usr/bin/env zx
useBash();

await $`lagoon config add \
  --graphql https://api.lagoon.dplplat01.dpl.reload.dk/graphql \
  --force \
  --ui https://ui.lagoon.dplplat01.dpl.reload.dk \
  --hostname 20.238.147.183 \
  --port 22 \
  --lagoon dplplat01`

await $`lagoon config default --lagoon dplplat01`

// verify that dplplat01 is the active lagoon
echo(await $`lagoon config list`)

function getFailedDeployments(environmentType) {
  return $.sync`lagoon raw --raw "query allProjects {
    allProjects {
      name
      environments(type: ${environmentType}) {
        name
        deployments(limit: 1) {
          status
          created
        }
      }
    }
  }" | jq -r '.allProjects[] | .name as $name | .environments[].deployments[] | select(.status == "failed") | ($name)'`.valueOf();
}

function redeployDeployments(environmentType, environmentName, allowRedeployAttemps) {
  const failedDeployments = getFailedDeployments(environmentType);
  console.log(failedDeployments);
}

const wait = ms => new Promise(res => setTimeout(res, ms));

while(true) {
  redeployDeployments("PRODUCTION", "main", 6);
  redeployDeployments("DEVELOPMENT", "moduletest", 3);
  echo("sleeping for 5 minutes before redeploying again");
  await wait(300000);
}
