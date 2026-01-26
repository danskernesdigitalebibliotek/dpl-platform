#!/usr/bin/env zx

cd('../../../infrastructure');
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


async function restoreFiles(nginxBackup, project, environment) {
  const filesBackup = await findBackupFile(nginxBackup);
  await copyFileToCliPod(filesBackup, project, environment);
  await importFiles(filesBackup, project, environment);
}

async function restoreDatabase(dbBackup, project, environment) {
  const databaseBackup = await findBackupFile(dbBackup);
  await copyFileToCliPod(databaseBackup, project, environment);
  await importBackupIntoDatabase(databaseBackup, project, environment);
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

async function importBackupIntoDatabase(file, project, environment) {
  console.log(file);
  let uncompressedBackup;
  try {
    uncompressedBackup = await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar -zxvf /tmp/${file} --directory /tmp"`
  } catch(error) {
    echo(error);
    throw Error("failed to extract database backup", { cause: error });
  }
  echo("Database backup file was unpacked");

  try {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- sh -c "drush sql:drop -y && drush sql:connect < /tmp/${uncompressedBackup}"`
  } catch(error) {
    echo(error);
    throw Error("Import of database backup failed", { cause: error });
  }
  echo("Database restored");
}

async function importFiles(file, project, environment) {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- sh -c "shopt -s extglob"`
  try {
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- sh -c "rm -rf /app/web/sites/default/files/!(php) && shopt -u extglob"`
  } catch(error) {
    echo(error);
    throw Error("Import of database backup failed", { cause: error });
  }
  echo("Existing files removed from /web/sites/default/files");

  try {
    // await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar -zxvf /tmp/${file} --directory /tmp data/nginx"`
    await $`kubectl exec -n ${project}-${environment} deploy/cli -- bash -c "tar --strip 2 --gzip --extract --file /tmp/${file} --directory /app/web/sites/default/files data/nginx"`
  } catch(error) {
    echo(error);
    throw Error("failed to extract files backup", { cause: error });
  }
  echo("Files restored");
} 
