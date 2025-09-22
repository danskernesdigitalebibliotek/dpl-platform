#!/usr/bin/env zx

echo(chalk.yellow("Will now patch lagoon-env for every environment with the connection details for the internal DB"));
echo("");

const sites = await $`cat ../../../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

// These sites was setup differently than the production sites.
const blackList = [
  "customizable-canary",
  "staging",
  "canary",
  "staging",
  "bibliotek-test",
  "solrod2",
];

for await (const site of sites.lines()) {
  if(blackList.includes(site)) {
    continue;
   }
    await makeBackupWorkAgain(site, "main");
  if (await isWebmaster(site)) {
    await makeBackupWorkAgain(site, "moduletest");
  }
}

async function makeBackupWorkAgain(site, environmentType = "main") {
  echo(chalk.green(`Reconfiguring: ${site}-${environmentType}`));
  const dbConnectionInfo = await getDbConnectionInfo(site, environmentType);
  //We are using console.log here instead of zx's echo, because echo doesn't inspect the returned object.
  console.log(dbConnectionInfo);
  await updateMariaDBConsumer(site, dbConnectionInfo, environmentType);
}

async function isWebmaster(project) {
   const result = await $`cat ../../../host_mount/environments/dplplat01/sites.yaml | yq '.sites.${project}.plan'`;
   return result.stdout === "webmaster\n" ? true : false;
}

async function getDbConnectionInfo(site, environment = "main") {
  const password = await $`kubectl get secret -n ${site}-${environment} database-secret --template={{.data.password}} | base64 -d`;
  const service = await $`kubectl get mariadbconsumer -n ${site}-${environment} mariadb --template={{.spec.consumer.services.primary}}`;
  const readReplicaServices = await $`kubectl get mariadbconsumer -n ${site}-${environment} mariadb --template={{.spec.consumer.services.replicas}}`;
  const readReplicaService = readReplicaServices.text().substring(1, readReplicaServices.text().length -1);;

  return {
    database: `database-${site}-${environment}`,
    password: password.text(),
    user: `database-user-${site}-${environment}`,
    hostname: "mariadb-10-6-22-production-1.mariadb-10-6-22-production-1.svc.cluster.local",
    service: service.text(),
    readReplica: readReplicaService,
  }
}

async function updateMariaDBConsumer(site, dbConnectionInfo, environment = "main") {
  await $`kubectl patch configmap -n ${site}-${environment} lagoon-env -p '{"data": { "MARIADB_DATABASE": "${dbConnectionInfo.database}", "MARIADB_HOST": "${dbConnectionInfo.hostname}", "MARIADB_PASSWORD": "${dbConnectionInfo.password}", "MARIADB_READREPLICA_HOSTS": "${dbConnectionInfo.hostname}", "MARIADB_USERNAME": "${dbConnectionInfo.user}"}}'`
}
