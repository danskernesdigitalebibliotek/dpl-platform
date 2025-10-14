#!/usr/bin/env zx
// This script takes a backup of the Lagoon Core API database, which Amazee suggests before running an ugprade to Lagoon Core: [https://docs.lagoon.sh/installing-lagoon/update-lagoon/#api-db]

echo(chalk.yellow("Getting a backup of the lagoon-core-api-db"));
try {
  await $`kubectl --namespace lagoon-core exec -it lagoon-core-api-db-0 -- \
      sh -c 'mysqldump --max-allowed-packet=500M --events \
      --routines --quick --add-locks --no-autocommit \
      --single-transaction infrastructure | gzip -9 > \
      /var/lib/mysql/backup/$(date +%Y-%m-%d).infrastructure.sql.gz'`;
} catch(error) {
  throw Error("An error occured while making the database backup, the program will end now", { cause: error});
}

try {
  await $`kubectl cp lagoon-core/lagoon-core-api-db-0:/var/lib/mysql/backup/$(date +%Y-%m-%d).infrastructure.sql.gz ./lagoon-core-api-db-backup.infrastructure.sql.gz`
} catch(error) {
  throw Error("Failed to copy the backup from lagoon-core-api-db-0 to local machine", { cause: error});
}

echo(chalk.green("Backup complete. The file can now be found at the root of the project"))


