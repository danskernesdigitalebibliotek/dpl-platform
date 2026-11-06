#!/usr/bin/env zx

const excludedProject = ["dpl-cms", "dpl-bnf", "dpl-web", "dpl-web-bnf"];

const lagoonQuery = (environmentType) => `query allProjects {
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
}`;

const possibleStatuses = ["complete", "failed", "cancelled"];
const status = `${argv.status}`
if (!status || typeof status=== "undefined") {
  throw Error("No 'status' provided, exiting. Possible status' are: 'complete', 'failed', 'cancelled'. If you don't know which to run, you probably want to run with 'failed'")
}
if (!possibleStatuses.includes(status)) {
  throw Error(`Desired status "${status}" is unkown. Use 'complete', 'failed' or 'cancelled'`);
}

const environmentsWithStatus = await getEnvironmentsWithStatus(status);
await redeployEnvironmentsWithStatus(environmentsWithStatus);
 
async function getEnvironmentsWithStatus(status) {
  const jsonProductionEnvs = await $`lagoon raw --raw ${lagoonQuery("PRODUCTION")}`;
  const jsonDevelopmentEnvs = await $`lagoon raw --raw ${lagoonQuery("DEVELOPMENT")}`;
  const productionEnvs = JSON.parse(jsonProductionEnvs.stdout);
  const developmentEnvs = JSON.parse(jsonDevelopmentEnvs.stdout);

  const allProjects = [...productionEnvs.allProjects, ...developmentEnvs.allProjects];

  const redeployableEnvs = allProjects.filter(project => !excludedProject.includes(project.name))
    .filter(project => project.environments.length > 0)
    .filter((project) => project.environments[0].deployments[0].status === status)

  return redeployableEnvs;
}

async function redeployEnvironmentsWithStatus(environmentsWithStatus) {
  if (!environmentsWithStatus.length) {
    console.log("No environments to redeploy - Done");
    return;
  }
  console.log("Redeploying environments")
  for await (const env of environmentsWithStatus) {
    console.log(`${env.name}-${env.environments[0].name}`)
    await $`lagoon deploy latest -p ${env.name} -e ${env.environments[0].name} --force`
  }
}
