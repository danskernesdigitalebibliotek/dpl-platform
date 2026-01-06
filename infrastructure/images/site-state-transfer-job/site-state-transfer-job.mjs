#!/usr/bin/env zx

const sourceNamespace = `${process.argv[3]}`;
if (!sourceNamespace) {
  throw Error("missing 'sourceNamespace'");
}

const sourceSshHost = `${process.argv[4]}`;
if (!sourceSshHost) {
  throw Error("missing 'sourceSshHost'");
}

const targetNamespace = `${process.argv[5]}`;
if (!targetNamespace) {
  throw Error("missing 'targetNamespace'");
}

const sshHost = sourceSshHost;
await makeDatabaseDump(sourceNamespace, sourceSshHost);
const targetDatabaseConnectionInfo = await getDatabaseConnectionInfo(targetNamespace);
await syncDatabaseDumpToTarget(targetNamespace, sshHost, targetDatabaseConnectionInfo);
await syncFileFromSourceToTarget(sourceNamespace, targetNamespace, sshHost);
await runDrushDeployForStateTransferToTakeEffect(targetNamespace);

echo(`${sourceNamespace} has been transfered from 01 to 02`);


async function runDrushDeployForStateTransferToTakeEffect(targetNamespace) {
  echo(`Starting 'drush deploy' in ${targetNamespace}`);
  try {
      await $`kubectl exec -n ${targetNamespace} deployment/cli -- bash -c "drush deploy"`;
  } catch (error) {
      echo(`Failed to run drush deploy from CLI pod in target namespace ${targetNamespace}`, error.stderr);
      throw Error(`Failed to run drush deploy from CLI pod in target namespace ${targetNamespace}`, { cause: error });
  }
}

async function syncFileFromSourceToTarget(sourceNamespace, targetNamespace, sshHost) {
  echo(`Now moving files from ${sourceNamespace} to ${targetNamespace}`);
  // The IP here is the lagoon SSH host and it is documented here: https://github.com/danskernesdigitalebibliotek/dpl-platform/blob/main/docs/runbooks/connecting-the-lagoon-cli.md#configure-your-local-lagoon-cli
  try {
      await $`kubectl exec -n ${targetNamespace} deployment/cli -- rsync --omit-dir-times --recursive --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=/styles/* --delete-excluded ${sourceNamespace}@${sshHost}:/app/web/sites/default/files/ /app/web/sites/default/files`;
  } catch (error) {
      echo(`Failed to rsync files from ${targetNamespace} to ${sourceNamespace}`, error.stderr);
      throw Error(`Failed to rsync files from ${targetNamespace} to ${sourceNamespace}`, { cause: error });
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

async function makeDatabaseDump(sourceNamespace, sshHost) {
  echo(`Dumping ${sourceNamespace} database to /tmp/${sourceNamespace}-dump.sql`);

  try {
    await $`kubectl exec -n ${sourceNamespace} deploy/cli -- ssh ${sourceNamespace}@${sshHost} "drush sql:dump --result-file=/tmp/${sourceNamespace}-dump.sql"`
  } catch(error) {
    echo(`Failed to make database dump in ${sourceNamespace} CLI pod`, error.stderr);
    throw Error(`Failed to make database dump in ${sourceNamespace} CLI pod`, { cause: error });
  }

  echo(`dump of ${sourceNamespace} database done`);
}

async function syncDatabaseDumpToTarget(sourceNamespace, sshHost, databaseConnectionInfo) {
  echo(`Syncing and then importing ${sourceNamespace} database dump from 01 to 02`);

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = databaseConnectionInfo;

  try {
    await $`kubectl exec -n ${sourceNamespace} deployment/cli -- rsync -vz ${sourceNamespace}@${sshHost}:/tmp/${sourceNamespace}-dump.sql /tmp/${sourceNamespace}-dump.sql`;
  } catch(error) {
    echo(`Failed to move ${sourceNamespace} dump from 01 to 02`, error.stderr);
    throw Error(`Failed to move ${sourceNamespace} dump from 01 to 02`, { cause: error })
  }

  try {
    await $`kubectl exec -n ${sourceNamespace} deployment/cli -- bash -c "drush sql-drop && mariadb --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} ${databaseName} < /tmp/${sourceNamespace}-dump.sql"`
  } catch(error) {
    echo(`Failed to import dump into 02's ${sourceNamespace} database`, error.stderr);
    throw Error(`Failed to import dump into ${sourceNamespace} database`, { cause: error });
  }

  echo(`database has been transfered from ${sourceNamespace} has been transfered from 01 to 02`);
}
