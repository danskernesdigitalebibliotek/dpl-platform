#!/usr/bin/env zx
// This script takes a backup of Lagoon's Keycloak DB, which Amazee suggests before running an ugprade to Lagoon Core: [https://docs.lagoon.sh/installing-lagoon/update-lagoon/#api-db]

echo(chalk.yellow("Getting a backup Lagoon's Keycloak DB"));
try {
  await $`kubectl --namespace lagoon-core exec -it lagoon-core-keycloak-db-0 -- \
    sh -c 'mysqldump --max-allowed-packet=500M --events \
    --routines --quick --add-locks --no-autocommit \
    --single-transaction keycloak | gzip -9 > \
    /var/lib/mysql/backup/$(date +%Y-%m-%d).keycloak.sql.gz'`;
} catch(error) {
  throw Error("An error occured while making keycloaks database backup, the program will end now", { cause: error});
}

try {
  await $`kubectl cp lagoon-core/lagoon-core-keycloak-db-0:/var/lib/mysql/backup/$(date +%Y-%m-%d).keycloak.sql.gz ./lagoon-core-keycloak-db-0-backup.sql.gz`
} catch(error) {
  throw Error("Failed to copy the backup from lagoon-core-keycloak-db-0 to local machine", { cause: error});
}

echo(chalk.green("Backup complete. The file can now be found at the root of the project"))


