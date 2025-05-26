#!/usr/bin/env zx

const projectName = `${process.argv[3]}`;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

const azureDatabaseHost = $.env.AZURE_DATABASE_HOST;



  }
}

}


echo(`Starting 'drush deploy' in ${projectName}-moduletest`);
try {
  await $`kubectl exec -n ${projectName}-moduletest deployment/cli -- bash -c "drush deploy"`
} catch(error) {
  echo("The file move failed for ${projectName} moduletest", error.stderr);
  throw Error("The file move failed for ${projectName} moduletest", { cause: error });
}

echo(`File reset for ${projectName} complete`);
