#!/usr/bin/env zx

echo(chalk.yellow("Will now reconfigure MariaDBConsumers"));
echo("");

const sites = await $`cat ../../../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

// These sites was setup differently than the production sites.
const blackList = [
  "customizable-canary",
  "staging",
  "canary",
  "staging",
  "bibliotek-test"
];

for await (const site of sites.lines()) {
  if(blackList.includes(site)) {
    continue;
   }
    await reconfigureMariaDbConsumerAndServices(site, "main");
  if (await isWebmaster(site)) {
    await reconfigureMariaDbConsumerAndServices(site, "moduletest");
    break;
  }
}

async function reconfigureMariaDbConsumerAndServices(site, environmentType = "main") {
  echo(chalk.green(`Reconfiguring: ${site}-${environmentType}`));
  const dbConnectionInfo = await getDbConnectionInfo(site, environmentType);
  //We are using console.log here instead of zx's echo, because echo doesn't inspect the returned object.
  console.log(dbConnectionInfo);
  await updateMariaDBConsumer(site, dbConnectionInfo, environmentType);
  await updateMariaDbServices(site, dbConnectionInfo, environmentType);
  try {
    await $`lagoon deploy latest -p ${site} -e ${environmentType} --force`;
  } catch(error) {
    throw Error(`failed to deploy ${site}-${environmentType} post updating MariaDbConsumer and services`);
  }
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
  await $`kubectl patch mariadbconsumer -n ${site}-${environment} mariadb --type='json' -p='[{"op": "replace", "path": "/spec/consumer/database", "value": ${dbConnectionInfo.database}}]'`
  await $`kubectl patch mariadbconsumer -n ${site}-${environment} mariadb --type='json' -p='[{"op": "replace", "path": "/spec/consumer/password", "value": ${dbConnectionInfo.password}}]'`
  await $`kubectl patch mariadbconsumer -n ${site}-${environment} mariadb --type='json' -p='[{"op": "replace", "path": "/spec/consumer/username", "value": ${dbConnectionInfo.user}}]'`
  await $`kubectl patch mariadbconsumer -n ${site}-${environment} mariadb --type='json' -p='[{"op": "replace", "path": "/spec/provider/hostname", "value": ${dbConnectionInfo.hostname}}]'`
  await $`kubectl patch mariadbconsumer -n ${site}-${environment} mariadb --type='json' -p='[{"op": "replace", "path": "/spec/provider/readReplicas", "value": [${dbConnectionInfo.hostname}]}]'`
}

async function updateMariaDbServices(site, dbConnectionInfo, environment = "main") {
  await $`kubectl patch svc -n ${site}-${environment} ${dbConnectionInfo.service} --type='json' -p='[{"op": "replace", "path": "/spec/externalName", "value": ${dbConnectionInfo.hostname}}]'`
  await $`kubectl patch svc -n ${site}-${environment} ${dbConnectionInfo.readReplica} --type='json' -p='[{"op": "replace", "path": "/spec/externalName", "value": ${dbConnectionInfo.hostname}}]'`
}

echo(chalk.green("done"));
echo("")

