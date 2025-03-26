#!/usr/bin/env zx

const projectName = $1;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

console.log(`Reseting files from ${projectName}-main to ${projectName}-moduletest
  \n
  Will now delete all files and folder in '/app/web/sites/default/files'
  \n
`);

try {
  // This will throw as there's a long running PHP process that keeps using
  // a file in a /php folder inside the CLI container
  // Emptying the folder is however successfull and we should ensure the
  // program doesn't exit;
  await $`kubectl exec -n ${projectName}-moduletest deploy/cli -- bash -c rm -fr /app/web/sites/default/files`
} catch(error) {
  if(error.exitCode != 1) {
    throw Error("unexpected error", error.stderr);
  }
  console.log("As expected, the deletion of all files and folders in '/app/web/default/files' threw an 'exit 1'", error);
}

console.log(`Will now move files from ${projectName}-main to ${projectName}-moduletest`);

try {
  await $` kubectl exec -n ${projectName}-main deploy/cli -- tar cf - /app/web/sites/default/files | kubectl exec -i -n ${projectName}-moduletest deploy/cli -- tar xvf - -C /`;
} catch(error) {
  console.log("file move failed", error.stderr);
}

console.log(`File reset for ${projectName}-moduletest complete`);
