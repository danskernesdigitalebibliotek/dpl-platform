#!/usr/bin/env zx

console.log("Creating webhooks for 'dplplat02' in every site repo");

const sites = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

for await (const site of sites.lines()) {
  // if(site != "kobenhavn") continue;
  echo(site);
  await createWebhookForSiteRepo(site);
}

async function createWebhookForSiteRepo(site) {
  try {
    await $`echo '{"name":"web","active":true,"events":["push","pull_request"],"config":{"url":"https://webhookhandler.lagoon.dplplat02.dpl.reload.dk","content_type":"json","insecure_ssl":"0"}}' | gh api repos/danishpubliclibraries/env-${site}/hooks --input - -X POST`    
  } catch(error) {
    const errorString = error.stdout;
    const errorObject = JSON.parse(errorString);
    if(errorObject.status == "422") {
      echo("webhook already exists");
      return;
    }
    echo("some other error occured", error);
  }
}
