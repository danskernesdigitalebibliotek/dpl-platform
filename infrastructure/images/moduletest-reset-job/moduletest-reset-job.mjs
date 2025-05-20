#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const databaseConnectionInfo = await getDatabaseConnectionInfo(projectName);
await makeDatabaseDump(...databaseConnectionInfo, projectName);

echo(`Reseting files from ${projectName}-main to ${projectName}-moduletest
  \n
  Will now delete all files and folder in '/app/web/sites/default/files'
  \n
  on ${projectName}-moduletest
`);

try {
  // This will throw as there's a long running PHP process that keeps using
  // a file in a /php folder inside the CLI container
  // Emptying the folder is however successfull and we should ensure the
  // program doesn't exit;
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "rm -fr /app/web/sites/default/files"`
} catch(error) {
  if(error.exitCode != 1) {
    throw Error("unexpected error", { cause: error });
  }
  echo("As expected, the deletion of all files and folders in '/app/web/default/files' threw an 'exit 1'", error);
}

echo(`Now moving files from ${projectName}-main to ${projectName}-moduletest`);
try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "rsync --omit-dir-times --recursive --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=css/* --exclude=js/* --exclude=styles/* --delete-excluded ${projectName}-main@20.238.147.183:/app/web/sites/default/files/ /app/web/sites/default/files/"`
} catch(error) {
  echo("The file move failed for ${projectName} moduletest", error.stderr);
  throw Error("The file move failed for ${projectName} moduletest", { cause: error });
}


echo(`Starting 'drush deploy' in ${projectName}-moduletest`);
try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush deploy"`
} catch(error) {
  echo("The file move failed for ${projectName} moduletest", error.stderr);
  throw Error("The file move failed for ${projectName} moduletest", { cause: error });
}

echo(`File reset for ${projectName} complete`);

async function getDatabaseConnectionInfo(projectName) {
  echo(`Now getting ${projectName}'s database connection details`);
  let configMapJson;
  try {
    configMapJson = await $`kubectl get -n ${projectName}-main configmap lagoon-env -o json`
  } catch(error) {
    echo("Database sync for ${projectName} moduletest failed", error.stderr);
    throw Error("Database sync for ${projectName} moduletest failed", { cause: error });
  }

  const originalDatabaseConnectionInfo = await $`jq -r '.data | { databaseName: .MARIADB_DATABASE, databaseHost: .MARIADB_HOST, databasePassword: .MARIADB_PASSWORD, datatbaseUser: .MARIADB_USERNAME}'`;
  const overrideDatabaseConnectionInfo = await $`jq -r '.data | { databaseName: .OVERRIDE_MARIADB_DATABASE, databaseHost: .OVERRIDE_MARIADB_HOST, databasePassword: .OVERRIDE_MARIADB_PASSWORD, datatbaseUser: .OVERRIDE_MARIADB_USERNAME}'`;
  // If overrideDatabaseConnectionInfo hgas info the project is using the incluster database, and we should the overrideDatabaseConnectionInfo to connecto the database.
  let databaseConnectionInfo;
  if(typeof overrideDatabaseConnectionInfo === "string") {
    databaseConnection = overrideDatabaseConnectionInfo;
    databaseConnectionInfo.override = true;
  } else {
    databaseConnection = originalDatabaseConnectionInfo;
    databaseConnectionInfo.override = false;
  }

  return databaseConnectionInfo;
}

async function makeDatabaseDump(databaseUser, databasePassword, databaseName, databaseHost, override = false, projectName) {
  echo(`Will now sync dump ${projectName}-main's database`);

  const namespace = projectName + "-main";
  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb-dump --user=${databaseUser} --host=${getDatabaseHost(databaseHost, namespace, override)} --password=${databasePassword} --ssl=false --skip-add-locks --single-transaction ${databaseName} > /tmp/dump.sql"`
  } catch(error) {
    echo("Database sync for ${projectName} moduletest failed", error.stderr);
    throw Error("Database sync for ${projectName} moduletest failed", { cause: error });
  }

  echo(`Database reset for ${projectName} complete`);
}

function getDatabaseHost(databaseHost, namespace, override = false) {
  // We are in the middle of switching to an incluster database. The incluster database has uses the same hostname no matter the namespace calling.
  // The the database accessed via Lagoon uses the following host format: svcName.environmentNamespace.svc.cluster.local.
  // The svcName is the non-override hostname found in the configmap lagoon-env.
  if(override === false) {
    return databaseHost;
  }
  return `${databaseHost}.${namespace}.svc.cluster.local`;
}

async function clearDatabaseBeforeUploading() {
  
}

async function importMainDumpIntoModuletestDatabase(databaseUser, databasePassword, databaseName, databaseHost) {
  
}
