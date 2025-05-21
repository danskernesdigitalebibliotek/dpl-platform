#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const sourceNamespace = projectName + "-main";
const sourceDatabaseConnectionInfo = await getDatabaseConnectionInfo(sourceNamespace);
await makeDatabaseDump(...sourceDatabaseConnectionInfo, projectName);
const targetNamespace = projectName + "-main";
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);
await importMainDumpIntoModuletestDatabase(...targetDatabaseConnectionInfo, projectName);

echo(`Reseting files from ${projectName}-main to ${projectName}-moduletest
  \n
  Will now delete all files and folder in '/app/web/sites/default/files'
  \n
  on ${projectName}-moduletest
`);

// Do we actually need to do this - rsync should handle the removal of files the source doesn't have
// await deleteFilesFolder(projectName);
await syncFileFromSourceToTarget(projectName);

await runDrushDeployForStateTransferToTakeEffect();

echo(`File reset for ${projectName} complete`);


async function runDrushDeployForStateTransferToTakeEffect() {
  echo(`Starting 'drush deploy' in ${projectName}-moduletest`);
  try {
      await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush deploy"`;
  } catch (error) {
      echo(`Failed to run drush deploy from CLI pod in namespace ${projectName}-moduletest`, error.stderr);
      throw Error(`Failed to run drush deploy from CLI pod in namespace ${projectName}-moduletest`, { cause: error });
  }
}

async function syncFileFromSourceToTarget(projectName) {
  echo(`Now moving files from ${projectName}-main to ${projectName}-moduletest`);
  try {
      await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "rsync --omit-dir-times --recursive --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=css/* --exclude=js/* --exclude=styles/* --delete-excluded ${projectName}-main@20.238.147.183:/app/web/sites/default/files/ /app/web/sites/default/files/"`;
  } catch (error) {
      echo(`The file move failed for ${projectName} moduletest`, error.stderr);
      throw Error(`The file move failed for ${projectName} moduletest`, { cause: error });
  }
}

// async function deleteFilesFolder(projectName) {
//     try {
//         await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "rm -fr /app/web/sites/default/files"`;
//     } catch (error) {
//         if (error.exitCode != 1) {
//             throw Error("unexpected error", { cause: error });
//         }
//         echo("As expected, the deletion of all files and folders in '/app/web/default/files' threw an 'exit 1'", error);
//     }
// }

async function getDatabaseConnectionInfo(namespace) {
  echo(`Now getting ${namespace}'s database connection details`);
  let configMapJson;
  try {
    configMapJson = await $`kubectl get -n ${namespace} configmap lagoon-env -o json`
  } catch(error) {
    echo(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, error.stderr);
    throw Error(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, { cause: error });
  }

  const originalDatabaseConnectionInfo = await $`${configMapJson} | jq -r '.data | { databaseName: .MARIADB_DATABASE, databaseHost: .MARIADB_HOST, databasePassword: .MARIADB_PASSWORD, datatbaseUser: .MARIADB_USERNAME}'`;
  const overrideDatabaseConnectionInfo = await $`${configMapJson} | jq -r '.data | { databaseName: .OVERRIDE_MARIADB_DATABASE, databaseHost: .OVERRIDE_MARIADB_HOST, databasePassword: .OVERRIDE_MARIADB_PASSWORD, datatbaseUser: .OVERRIDE_MARIADB_USERNAME}'`;
  // If overrideDatabaseConnectionInfo, the project is using the incluster database, and we should the overrideDatabaseConnectionInfo to connecto the database.
  let databaseConnectionInfo;
  if(typeof overrideDatabaseConnectionInfo === "string") {
    databaseConnectionInfo = overrideDatabaseConnectionInfo;
    databaseConnectionInfo.override = true;
  } else {
    databaseConnectionInfo = originalDatabaseConnectionInfo;
    databaseConnectionInfo.override = false;
  }

  return databaseConnectionInfo;
}

async function makeDatabaseDump(databaseUser, databasePassword, databaseName, databaseHost, override = false, projectName) {
  echo(`Will now sync dump ${projectName}-main's database`);

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb-dump --user=${databaseUser} --host=${getDatabaseHost(databaseHost, projectName, override)} --password=${databasePassword} --ssl=false --skip-add-locks --single-transaction ${databaseName} > /tmp/${projectName}-dump.sql"`
  } catch(error) {
    echo(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, error.stderr);
    throw Error(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, { cause: error });
  }

  echo(`Database dump for ${projectName} complete`);
}

function getDatabaseHost(databaseHost, projectName, override = false) {
  // We are in the middle of switching to an incluster database. The incluster database has uses the same hostname no matter the namespace calling.
  // The the database accessed via Lagoon uses the following host format: svcName.environmentNamespace.svc.cluster.local.
  // The svcName is the non-override hostname found in the configmap lagoon-env.
  if(override === false) {
    return databaseHost;
  }
  return `${databaseHost}.${projectName}-moduletest.svc.cluster.local`;
}

async function importMainDumpIntoModuletestDatabase(databaseUser, databasePassword, databaseName, databaseHost, override = false, projectName) {
  echo(`Importing ${projectName}-main's database dump in to ${projectName}-moduletest's database`);

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb --user=${databaseUser} --host=${getDatabaseHost(databaseHost, projectName, override)} --password=${databasePassword} ${databaseName} < /tmp/${projectName}dump.sql"`
  } catch(error) {
    echo(`Failed to import dump into ${projectName}-moduletest's database`, error.stderr);
    throw Error(`Failed to import dump into ${projectName}-moduletest's database`, { cause: error });
  }

  echo(`Database reset for ${projectName} complete`);
}
