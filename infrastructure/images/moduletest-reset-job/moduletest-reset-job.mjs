#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const azureDatabaseHost = $.env.AZURE_DATABASE_HOST;

const sourceNamespace = projectName + "-main";
const sourceDatabaseConnectionInfo = await getDatabaseConnectionInfo(sourceNamespace);
await makeDatabaseDump(sourceDatabaseConnectionInfo, projectName);
const targetNamespace = projectName + "-moduletest";
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);
await importMainDumpIntoModuletestDatabase(targetDatabaseConnectionInfo, projectName);


  }
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

echo(`Starting 'drush deploy' in ${projectName}-moduletest`);
try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush deploy"`
} catch(error) {
  echo("The file move failed for ${projectName} moduletest", error.stderr);
  throw Error("The file move failed for ${projectName} moduletest", { cause: error });
  let databaseConnectionInfo = {
    databaseName: "",
    databaseHost: "",
    databaseUser: "",
    databasePassword : "",
  };

  if(data.OVERRIDE_MARIADB_DATABASE != undefined) {
    databaseConnectionInfo.databaseName = data.OVERRIDE_MARIADB_DATABASE;
    databaseConnectionInfo.databaseHost = data.OVERRIDE_MARIADB_HOST;
    databaseConnectionInfo.databasePassword = data.OVERRIDE_MARIADB_PASSWORD;
    databaseConnectionInfo.databaseUser = data.OVERRIDE_MARIADB_USERNAME;
    databaseConnectionInfo.override = true;
  } else {
    databaseConnectionInfo.databaseName = data.MARIADB_DATABASE;
    databaseConnectionInfo.databaseHost = data.MARIADB_HOST;
    databaseConnectionInfo.databasePassword = data.MARIADB_PASSWORD;
    databaseConnectionInfo.databaseUser = data.MARIADB_USERNAME;
    databaseConnectionInfo.override = false;
  }

  return databaseConnectionInfo;
}

echo(`File reset for ${projectName} complete`);
async function makeDatabaseDump(databaseConnectionInfo, projectName) {
  echo(`Dumping ${projectName}-main's database to file`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
    override,
  } = databaseConnectionInfo;

  const host = getDatabaseHost(databaseHost, projectName, override);

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb-dump --user=${databaseUser} --host=${host} --password=${databasePassword} --ssl=false --skip-add-locks --single-transaction ${databaseName} > /tmp/${projectName}-dump.sql"`
  } catch(error) {
    echo(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, error.stderr);
    throw Error(`Failed to make database dump from ${projectName}-main to CLI pod in ${projectName}-moduletest`, { cause: error });
  }

  echo(`Database dump for ${projectName} complete`);
}

function getDatabaseHost(databaseHost, projectName, override = false) {
  // We are in the middle of switching to an incluster database. We therefore need to use the database the site is using to make a database transfer
  if(override === true) {
    return databaseHost;
  }
  return azureDatabaseHost;
}

async function importMainDumpIntoModuletestDatabase(databaseConnectionInfo, projectName) {
  echo(`Importing ${projectName}-main's database dump in to ${projectName}-moduletest's database`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
    override,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "mariadb --user=${databaseUser} --host=${getDatabaseHost(databaseHost, projectName, override)} --password=${databasePassword} ${databaseName} < /tmp/${projectName}-dump.sql"`
  } catch(error) {
    echo(`Failed to import dump into ${projectName}-moduletest's database`, error.stderr);
    throw Error(`Failed to import dump into ${projectName}-moduletest's database`, { cause: error });
  }

  echo(`Database reset for ${projectName} complete`);
}
