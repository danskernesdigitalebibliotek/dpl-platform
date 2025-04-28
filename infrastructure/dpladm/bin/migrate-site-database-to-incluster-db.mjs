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
async function createDatabaseGrantUserSecret(project, environment, password, dryRun) {
  echo(`Now migrating ${project}-${environment} database to incluser database`)

  echo(await $`helm upgrade --install --namespace ${project}-${environment}  --set password=${password}  mariadb-database ./dpladm/mariadb-database/ --dry-run`);

  if (dryRun === false) {
    echo("done")
    await $`exit 1`;
  }

  await $`helm upgrade --install --namespace ${project}-${environment}  --set password=${password}  mariadb-database ./dpladm/mariadb-database/`;
}
