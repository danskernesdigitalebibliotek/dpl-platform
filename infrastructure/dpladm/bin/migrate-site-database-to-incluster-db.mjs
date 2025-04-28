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
sleep(3000)
await dumpCurrentDatabaseIntoTmp(project, environment);
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

  if (dryRun === false) {
    echo("done")
    await $`exit 1`;
  }

  await $`helm upgrade --install --namespace ${project}-${environment}  --set password=${password}  mariadb-database ./dpladm/mariadb-database/`;
}
