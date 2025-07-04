#!/usr/bin/env zx

const project = `${argv.project}`;
if (!project || typeof project === "undefined") {
  throw Error("No 'project' provided");
}

const environment = `${argv.env}`;
if (!environment || typeof project === "undefined") {
  throw Error("No 'environment' provided");
}

if (typeof `${argv.dryrun}` === "undefined") {
  dryRun = false;
}

await dumpCurrentDatabaseIntoTmp(project, environment);
const password = await getInclusterDatabasePassword(project, environment);
await importDumpIntoInclusterDatabase(project, environment, password);
await createOverrideVariables(project, environment, password);
// we need to redeploy the environment for it to take effect ("force" forces yes to prompts)
await $`lagoon deploy latest --project ${project} --environment ${environment} --force`

async function getInclusterDatabasePassword(project, environment) {
  return await $`kubectl get secret -n ${project}-${environment} database-secret --template={{.data.password}} | base64 -d`;
}

async function createOverrideVariables(project, environment, password) {
  const overrideVariables = [
    {
      name: "MARIADB_DATABASE_OVERRIDE",
      value: `database-${project}-${environment}`,
    },
    {
      name: "MARIADB_USERNAME_OVERRIDE",
      value: `database-user-${project}-${environment}`,
    },
    {
      name: "MARIADB_PASSWORD_OVERRIDE",
      value: `${password}`,
    },
    {
      name: "MARIADB_HOST_OVERRIDE",
      value: "mariadb-10-6-22-production-1.mariadb-10-6-22-production-1.svc.cluster.local",
    },
    {
      name: "MARIADB_PORT_OVERRIDE",
      value: "3306",
    }
  ];

  for (const variable of overrideVariables) {
    try {
      await $`lagoon add variable --project ${project} --environment ${environment} --name ${variable.name} --scope global --value ${variable.value}`;
    } catch (error) {
      throw Error("failed to create or update variables for BNF and GO secrets", { cause: error });
    }
  }
}

async function importDumpIntoInclusterDatabase(project, environment, password) {
  echo(chalk.blue(`Importing ${project}-${environment} database into incluster database`));
  await $`kubectl exec -n mariadb-10-6-22-production-1 mariadb-10-6-22-production-1-0 -- bash -c "mariadb -udatabase-user-${project}-${environment} -p${password} --database database-${project}-${environment} --verbose < /tmp/dump.sql"`;
}

async function dumpCurrentDatabaseIntoTmp(project, environment) {
  echo(chalk.blue(`Dumping ${project}-${environment} database to /tmp/dump.sql`));
  const databaseConnectionDetails = await getCurrentDatabaseConnectionDetails(project, environment);
  await $`kubectl exec -n mariadb-10-6-22-production-1 mariadb-10-6-22-production-1-0 -- bash -c "mariadb-dump --user=${databaseConnectionDetails.user} --host=${databaseConnectionDetails.host}.${project}-${environment}.svc.cluster.local --password=${databaseConnectionDetails.password} --ssl=false --skip-add-locks --single-transaction ${databaseConnectionDetails.databaseName} --verbose > /tmp/dump.sql"`
}

async function getCurrentDatabaseConnectionDetails(project, environment) {
  const lagoonEnvConfigJson = await $`kubectl get configmap lagoon-env -n ${project}-${environment} --output=jsonpath='{.data}'`;
  const lagoonEnvConfig = JSON.parse(lagoonEnvConfigJson);
  return {
    user: lagoonEnvConfig.MARIADB_USERNAME,
    host: lagoonEnvConfig.MARIADB_HOST,
    password: lagoonEnvConfig.MARIADB_PASSWORD,
    databaseName: lagoonEnvConfig.MARIADB_DATABASE
  };
}
