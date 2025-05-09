#!/usr/bin/env zx

import * as crypto from "crypto";

const project = `${process.argv[3]}`;
if (!project) {
  throw Error("No 'project' provided");
}

const environment = `${process.argv[4]}`;
if (!environment) {
  throw Error("No 'environment' provided");
}

let dryRun = `${process.argv[5]}`;
if (typeof `${process.argv[5]}` === "undefined") {
  dryRun = false;
}

const password = crypto.randomBytes(32).toString("base64");

await createDatabaseGrantUserSecret(project, environment, password, dryRun);
// wait for database, user and secret to have been created, it takes a little bit of time
await sleep(3000)
await dumpCurrentDatabaseIntoTmp(project, environment);
await importDumpIntoInclusterDatabase(project, environment, password);
await createOverrideVariables(project, environment, password);
// we need to redeploy the environment for it to take effect ("force" forces yes to prompts)
await $`lagoon deploy latest --project ${project} --environment ${environment} --force`


async function createOverrideVariables(project, environment, password) {
  const overrideVariables = [
    {
      name: "MARIADB_DATABASE_OVERRIDE",
      value: `database-${project}-${environment}`,
    },
    {
      name: "MARIADB_USERNAME_OVERRIDE",
      value: `user-database-${project}-${environment}`,
    },
    {
      name: "MARIADB_PASSWORD_OVERRIDE",
      value: `${password}`,
    },
    {
      name: "MARIADB_HOST_OVERRIDE",
      value: "mariadb-10-6-01.mariadb-servers.svc.cluster.local",
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
  echo(`Importing ${project}-${environment} database into incluster database`);
  await $`kubectl exec -n mariadb-servers mariadb-10-6-01-0 -- bash -c "mariadb -uuser-database-${project}-${environment} -p${password} --database database-${project}-${environment} --verbose < /tmp/dump.sql"`
}

async function dumpCurrentDatabaseIntoTmp(project, environment) {
  echo(`Dumping ${project}-${environment} database to /tmp/dump.sql`);
  const databaseConnectionDetails = await getCurrentDatabaseConnectionDetails(project, environment)
  await $`kubectl exec -n mariadb-servers mariadb-10-6-01-0 -- bash -c "mariadb-dump --user=${databaseConnectionDetails.user} --host=${databaseConnectionDetails.host}.${project}-${environment}.svc.cluster.local --password=${databaseConnectionDetails.password} --ssl=false --skip-add-locks --single-transaction ${databaseConnectionDetails.databaseName} --verbose > /tmp/dump.sql"`
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

async function createDatabaseGrantUserSecret(project, environment, password, dryRun) {
  echo(`Now migrating ${project}-${environment} database to incluser database`)

  echo(await $`helm upgrade --install --namespace ${project}-${environment}  --set password=${password}  mariadb-database ./dpladm/mariadb-database/ --dry-run`);

  if (dryRun) {
    echo("done")
    await $`exit 1`;
  }

  await $`helm upgrade --install --namespace ${project}-${environment}  --set password=${password}  mariadb-database ./dpladm/mariadb-database/`;
}
