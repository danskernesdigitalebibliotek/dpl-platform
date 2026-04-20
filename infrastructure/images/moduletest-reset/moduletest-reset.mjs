#!/usr/bin/env zx

const sourceNamespace = `${argv.source}`;
if (!sourceNamespace ) {
  throw Error("No 'sourceNamespace' provided");
}
const targetNamespace = `${argv.target}`;
if (!targetNamespace) {
  throw Error("No 'targetNamespace' provided");
}

const sourceDatabaseConnectionInfo = await getDatabaseConnectionInfo(sourceNamespace);
await makeDatabaseDump(sourceDatabaseConnectionInfo, sourceNamespace, targetNamespace);
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);
await importMainDumpIntoModuletestDatabase(targetDatabaseConnectionInfo, sourceNamespace, targetNamespace);

await syncFileFromSourceToTarget(sourceNamespace, targetNamespace);

await runDrushDeployForStateTransferToTakeEffect(targetNamespace);

echo(`File reset for ${targetNamespace} complete`);


async function runDrushDeployForStateTransferToTakeEffect(targetNamespace) {
  echo(`Starting 'drush deploy' in ${targetNamespace}-moduletest`);
  try {
      await $`kubectl exec -n ${targetNamespace} deployment/cli -- bash -c "drush deploy"`;
  } catch (error) {
      echo(`Failed to run drush deploy from CLI pod in namespace ${targetNamespace}`, error.stderr);
      throw Error(`Failed to run drush deploy from CLI pod in namespace ${targetNamespace}`, { cause: error });
  }
}

async function syncFileFromSourceToTarget(sourceNamespace, targetNamespace) {
  echo(`Now moving files from ${sourceNamespace} to ${targetNamespace}`);
  // The IP here is the lagoon SSH host and it is documented here: https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/docs/runbooks/connecting-the-lagoon-cli.md#configure-your-local-lagoon-cli
  const sshHost = "130.226.25.97";
  try {
      await $`kubectl exec -n ${targetNamespace} deployment/cli -- bash -c "rsync --omit-dir-times --recursive --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=/styles/* --delete-excluded ${sourceNamespace}@${sshHost}:/app/web/sites/default/files/ /app/web/sites/default/files/"`;
  } catch (error) {
      echo(`Failed to sync files from ${sourceNamespace} to ${targetNamespace}`, error.stderr);
      throw Error(`Failed to sync files from ${sourceNamespace} to ${targetNamespace}`, { cause: error });
  }
}

async function getDatabaseConnectionInfo(namespace) {
  echo(`Getting ${namespace}'s database connection details`);
  let configMapJson;
  try {
    configMapJson = await $`kubectl get -n ${namespace} configmap lagoon-env -o json`
  } catch(error) {
    echo(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, error.stderr);
    throw Error(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, { cause: error });
  }

  const configmap = JSON.parse(configMapJson);
  const { data } = configmap;

  const databaseConnectionInfo = {
    databaseName: data.MARIADB_DATABASE,
    databaseHost: await $`kubectl get svc ${data.MARIADB_HOST} -n ${namespace} --template={{.spec.externalName}}`,
    databaseUser:  data.MARIADB_USERNAME,
    databasePassword: data.MARIADB_PASSWORD,
  };

  if(data.MARIADB_DATABASE_OVERRIDE) {
    echo('using OVERRIDE variables');
    databaseConnectionInfo.databaseName = data.MARIADB_DATABASE_OVERRIDE;
    databaseConnectionInfo.databaseHost = data.MARIADB_HOST_OVERRIDE;
    databaseConnectionInfo.databasePassword = data.MARIADB_PASSWORD_OVERRIDE;
    databaseConnectionInfo.databaseUser = data.MARIADB_USERNAME_OVERRIDE;
  }

  return databaseConnectionInfo;
}

async function makeDatabaseDump(databaseConnectionInfo, sourceNamespace, targetNamespace) {
  echo(`Dumping ${sourceNamespace}'s database to file`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${targetNamespace} deployment/cli -- bash -c "mariadb-dump --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} --ssl=false --skip-add-locks --single-transaction ${databaseName} > /tmp/${sourceNamespace}-dump.sql"`
  } catch(error) {
    echo(`Failed to make database dump from ${sourceNamespace} to CLI pod in ${targetNamespace}`, error.stderr);
    throw Error(`Failed to make database dump from ${sourceNamespace} to CLI pod in ${targetNamespace}`, { cause: error });
  }

  echo(`Database dump of ${sourceNamespace} complete`);
}

async function importMainDumpIntoModuletestDatabase(databaseConnectionInfo, sourceNamespace, targetNamespace) {
  echo(`Importing ${sourceNamespace}'s database dump in to ${targetNamespace}'s database`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${targetNamespace} deployment/cli -- bash -c "drush sql-drop && mariadb --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} ${databaseName} < /tmp/${sourceNamespace}-dump.sql"`
  } catch(error) {
    echo(`Failed to import dump into ${targetNamespace}'s database`, error.stderr);
    throw Error(`Failed to import dump into ${targetNamespace}'s database`, { cause: error });
  }

  echo(`Database reset for ${targetNamespace} complete`);
}
