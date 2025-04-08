#!/usr/bin/env zx

const projectName = process.argv[0];

if (!projectName) {
  throw Error("No 'projectName' provided");
}

echo(`Will now sync databases from ${projectName}-main to ${projectName}-moduletest`);

try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush sql-drop -y; drush -y sql-sync @lagoon.${projectName}-main @self --create-db"`
} catch(error) {
  echo("Database sync for ${projectName} moduletest failed", error.stderr);
  throw Error("Database sync for ${projectName} moduletest failed", { cause: error });
}

echo(`Database reset for ${projectName} complete`);

echo(`Reseting files from ${projectName}-main to ${projectName}-moduletest
  \n
  Will now delete all files and folder in '/app/web/sites/default/files'
  \n
  on ${projectName}-moduletest
`);

try {
  // This will throw as there's a long running PHP process that keeps using
  // a file in a /php folder inside the CLI container
  // Emptying the folder is however successfull and we should ensure the
  // program doesn't exit;
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c rm -fr /app/web/sites/default/files`
} catch(error) {
  if(error.exitCode != 1) {
    throw Error("unexpected error", { cause: error });
  }
  echo("As expected, the deletion of all files and folders in '/app/web/default/files' threw an 'exit 1'", error);
}

echo(`Now moving files from ${projectName}-main to ${projectName}-moduletest`);

try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush -y rsync @lagoon.${projectName}-main:%files @self:%files -- --omit-dir-times --no-perms --no-group --no-owner --no-times --chmod=ugo=rwX --delete --exclude=css/* --exclude=js/* --exclude=styles/* --delete-excluded"`
  // await $`kubectl exec -n ${projectName}-main deploy/cli -- tar cf - /app/web/sites/default/files | kubectl exec -i -n ${projectName}-moduletest deploy/cli -- tar xvf - -C /`;
} catch(error) {
  echo("The file move failed for ${projectName} moduletest", error.stderr);
  throw Error("The file move failed for ${projectName} moduletest", { cause: error });
}

echo(`File reset for ${projectName} complete`);
