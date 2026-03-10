#!/usr/bin/env zx

console.log("Creating webhooks for 'dplplat02' in every site repo");

const sites = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

for await (const site of sites.lines()) {
  echo(site)
  echo(chalk.blue(site));
  await deleteWebhookForSiteRepo(site);
}

async function deleteWebhookForSiteRepo(site) {
  console.log(site);
  const hookId = await getRepoWebhookId(site);
  if(!hookId) {
    echo(chalk.yellow("no hook id"));
    return;
  }
  await deleteRepoWebhook(site, hookId);
}

async function getRepoWebhookId(site) {
  let response;
  try {
    response = await $`gh api repos/danishpubliclibraries/env-${site}/hooks`
  } catch(error) {
    const errorString = error.stdout;
    const errorObject = JSON.parse(errorString);
    // if(errorObject.status == "422") {
    //   echo("webhook already exists");
    //   return;
    // }
    echo("some other error occured", error);
  }
  const json = JSON.parse(response);
  if(json.length !== 0) return json[0].id;
  return 0;
}

async function deleteRepoWebhook(site, hookId) {
  try {
    await $`gh api -X DELETE /repos/danishpubliclibraries/env-${site}/hooks/${hookId}`
  } catch(error) {
    const errorString = error.stdout;
    console.log(error)
    const errorObject = JSON.parse(errorString);
    // if(errorObject.status == "422") {
    //   echo("webhook already exists");
    //   return;
    // }
    echo("some other error occured", error);
  }
}
