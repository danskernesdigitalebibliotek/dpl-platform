#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const azureDatabaseHost = $.env.AZURE_DATABASE_HOST;

const sourceNamespace = projectName + "-main";
const sourceDatabaseConnectionInfo = await getDatabaseConnectionInfo(sourceNamespace);
const targetNamespace = projectName + "-moduletest";
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);


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
