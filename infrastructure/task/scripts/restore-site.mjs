#!/usr/bin/env zx

const project = `${argv.project}`;
if (!project || typeof project === "undefined") {
  throw Error("No 'project' provided, exiting.");
}

const environment = `${argv.environment}`;
if (!environment || typeof project === "undefined") {
  throw Error("No 'environment' provided, exiting.");
}

let dbBackup = `${argv.dbBackup}`;
if (!("dbBackup" in argv)) {
  echo("No path to a database backup provided (missing --dbBackup flag)");
  dbBackup = false;
}

let nginxBackup = `${argv.nginxBackup}`;
if (!("nginxBackup" in argv)) {
  echo("No path to files backup provided (missing --nginxBackup flag)");
  nginxBackup = false;
}

if (!nginxBackup && !dbBackup) {
  throw Error("No backup files provided. Use --fileBackup and/or --dbBackup to provide paths to either Nginx backup file or database backkup file");
}

if (dbBackup) {
  echo("Now restoring database");
  await restoreDatabase(dbBackup, project, environment);
}

if (nginxBackup) {
  echo("Now restoring files");
  await restoreFiles(nginxBackup, project, environment);
}

echo("Your restore has now completed");
echo(`You should now run a deployment through Lagoon UI to make the restore take effect: https://ui.lagoon.dplplat02.dpl.reload.dk/projects/${project}/${project}-${environment}`);


async function restoreFiles(nginxBackup, project, environment) {
  const filesBackup = await findBackupFile(nginxBackup);
  await copyFileToCliPod(filesBackup, project, environment);
  await importFiles(filesBackup, project, environment);
}

async function restoreDatabase(dbBackup, project, environment) {
  const databaseBackup = await findBackupFile(dbBackup);
  await copyFileToCliPod(databaseBackup, project, environment);
  const dbConnectionInfo = await getDatabaseConnectionInfo(`${project}-${environment}`);
  await importBackupIntoDatabase(databaseBackup, dbConnectionInfo, project, environment);
}

async function findBackupFile(backupFile) {
  return backupFile;
  let path;
  try {
    path =  $`ls | grep ${backupFile}`;
  } catch(error) {
    echo(error);
  }
  
  console.log(path);
  echo(path);
  return path.valueOf();
}

async function copyFileToCliPod(file, project, environment) {
  try {
    await $`kubectl cp ${file} ${project}-${environment}/$(kubectl -n ${project}-${environment} get pod -l app.kubernetes.io/instance=cli -o jsonpath='{.items[0].metadata.name}'):/tmp/${file}`;
  } catch(error) {
    echo(error);
  }
  echo(`${file} was moved to /tmp in CLI pod`);
}

async function getDatabaseConnectionInfo(namespace) {
  echo(`Getting ${namespace}'s database connection details`);
  let configMapJson;
  try {
    configMapJson = await $`kubectl get -n ${namespace} configmap lagoon-env -o json`
  } catch (error) {
    echo(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, error.stderr);
    throw Error(`Failed to get configmap "lagoon-env" in namespace ${namespace}`, { cause: error });
  }

  const configmap = JSON.parse(configMapJson);
  const { data } = configmap;

  const databaseConnectionInfo = {
    databaseName: data.MARIADB_DATABASE,
    databaseHost: await $`kubectl get svc ${data.MARIADB_HOST} -n ${namespace} --template={{.spec.externalName}}`,
    databaseUser: data.MARIADB_USERNAME,
    databasePassword: data.MARIADB_PASSWORD,
  };

  if (data.MARIADB_DATABASE_OVERRIDE) {
    echo('using OVERRIDE variables');
    databaseConnectionInfo.databaseName = data.MARIADB_DATABASE_OVERRIDE;
    databaseConnectionInfo.databaseHost = data.MARIADB_HOST_OVERRIDE;
    databaseConnectionInfo.databasePassword = data.MARIADB_PASSWORD_OVERRIDE;
    databaseConnectionInfo.databaseUser = data.MARIADB_USERNAME_OVERRIDE;
  }

  return databaseConnectionInfo;
}

async function importBackupIntoDatabase(file, connectionInfo, project, environment) {
  console.log(file);
  let uncompressedBackup;
  try {
    uncompressedBackup = await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar -zxvf /tmp/${file} --directory /tmp"`
  } catch(error) {
    echo(error);
    throw Error("failed to extract database backup", { cause: error });
  }
  echo("Database backup file was unpacked");

  const {
    databaseName,
    databaseHost,
    databaseUser,
    databasePassword,
  } = connectionInfo;

  echo("dropping existing database");
  try {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- sh -c "drush sql-drop -y"`
  } catch(error) {
    echo(error);
    throw Error("drop of database failed", { cause: error });
  }

  echo(`importing '${uncompressedBackup}' into database`);
  try {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- sh -c "drush sql-drop -y && mariadb --user=${databaseUser} --host=${databaseHost} --password=${databasePassword} --database=${databaseName} < /tmp/${uncompressedBackup}"`
  } catch(error) {
    echo(error);
    throw Error("Import of database backup failed", { cause: error });
  }
  echo("Database restored");
}

async function importFiles(file, project, environment) {
  await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "shopt -s extglob"`
  try {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "rm -rf /app/web/sites/default/files/"`
  } catch(error) {
    echo(error);
  }
  echo("Existing files removed from /web/sites/default/files");

  try {
    // await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar -zxvf /tmp/${file} --directory /tmp data/nginx"`
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar --strip 2 --gzip --extract --file /tmp/${file} --directory /app/web/sites/default/files data/nginx"`
  } catch(error) {
    echo(error);
    throw Error("Failed to extract files backup. The task succeeded if the error is a utime error", { cause: error });
  }
  echo("Files restored");
} 
