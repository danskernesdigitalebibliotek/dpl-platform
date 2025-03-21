#!/usr/bin/env zx
useBash();

const time = function() {
  return $.sync`date +%T`;
}


await $`lagoon config add \
  --graphql https://api.lagoon.dplplat01.dpl.reload.dk/graphql \
  --force \
  --ui https://ui.lagoon.dplplat01.dpl.reload.dk \
  --hostname 20.238.147.183 \
  --port 22 \
  --lagoon dplplat01`

await $`lagoon config default --lagoon dplplat01`;

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
  }" | jq -r '.allProjects[] | .name as $name | .environments[].deployments[] | select(.status != "complete") | ($name)'`.valueOf().split("\n");
}

  const failedDeployments = getFailedDeployments(environmentType);
const redeployedDeployments = {};
const redeployBlackList = {};

function redeployDeployments(environmentType, environmentName, allowedRedeployAttempts) {
  console.log(`${time()} - Checking for ${environmentType} envs for failed deployments`);
  // We do not want to redeploy dpl-cms and dpl-bnf projects sites
  const failedDeployments = getFailedDeployments(environmentType).filter(deployment => !deployment.startsWith("dpl-"))
  if(failedDeployments.length <= 0) {
    console.log(`${time()} - No failed ${environmentType} deployments found - sleeping for 5 minutes`);
    return;
  }

  for(const deployment of failedDeployments) {
    if(isNaN(redeployedDeployments[`${deployment}-${environmentName}`])) {
      //First time through the redeployment loop we need to set the key with 0
      redeployedDeployments[`${deployment}-${environmentName}`] = 0;
    }
    if(redeployedDeployments[`${deployment}-${environmentName}`] >= allowedRedeployAttempts) {
      console.log(`${time()} - ${deployment}-${environmentName}: No attempts left`);
      const envUrl = $.sync`lagoon web -p ${deployment} -e ${environmentName}`.valueOf();
      redeployBlackList[`${deployment}-${environmentName}`] = envUrl.slice(7);
      console.log("url?",envUrl)
      delete redeployedDeployments[`${deployment}-${environmentName}`];
      continue;
    }
    console.log(`${time()} - Deploying: ${deployment}-${environmentName}`);
    $.sync`lagoon deploy latest -p "${deployment}" -e "${environmentName}" --force`;
    redeployedDeployments[`${deployment}-${environmentName}`] += 1;
  }

}

const wait = ms => new Promise(res => setTimeout(res, ms));

while(true) {
  redeployDeployments("PRODUCTION", "main", 6);
  redeployDeployments("DEVELOPMENT", "moduletest", 3);
  echo("sleeping for 5 minutes before redeploying again");
  await wait(300000);
}
