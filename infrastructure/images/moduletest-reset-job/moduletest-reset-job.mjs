#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const sourceNamespace = projectName + "-main";
const sourceDatabaseConnectionInfo = await getDatabaseConnectionInfo(sourceNamespace);
await makeDatabaseDump(sourceDatabaseConnectionInfo, projectName);
const targetNamespace = projectName + "-moduletest";
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);
await importMainDumpIntoModuletestDatabase(targetDatabaseConnectionInfo, projectName);

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
  // The IP here is the lagoon SSH host and it is documented here: https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/docs/runbooks/connecting-the-lagoon-cli.md#configure-your-local-lagoon-cli
  const sshHost = "20.238.202.21";
  try {
      await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "rsync --omit-dir-times --recursive --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=/styles/* --delete-excluded ${projectName}-main@${sshHost}:/app/web/sites/default/files/ /app/web/sites/default/files/"`;
  } catch (error) {
      echo(`The file move failed for ${projectName} moduletest`, error.stderr);
      throw Error(`The file move failed for ${projectName} moduletest`, { cause: error });
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

async function makeDatabaseDump(databaseConnectionInfo, projectName) {
  echo(`Dumping ${projectName}-main's database to file`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb-dump --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} --ssl=false --skip-add-locks --single-transaction ${databaseName} > /tmp/${projectName}-dump.sql"`
  } catch(error) {
    echo(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, error.stderr);
    throw Error(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, { cause: error });
  }

  echo(`Database dump for ${projectName} complete`);
}

async function importMainDumpIntoModuletestDatabase(databaseConnectionInfo, projectName) {
  echo(`Importing ${projectName}-main's database dump in to ${projectName}-moduletest's database`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush sql-drop && mariadb --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} ${databaseName} < /tmp/${projectName}-dump.sql"`
  } catch(error) {
    echo(`Failed to import dump into ${projectName}-moduletest's database`, error.stderr);
    throw Error(`Failed to import dump into ${projectName}-moduletest's database`, { cause: error });
  }

  echo(`Database reset for ${projectName} complete`);
}
