#!/usr/bin/env zx

const sites = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

for await (const site of sites.lines()) {
  // console.log(site);
  if(site == "customizable-canary" || site === "bibliotek-test") continue;
  const domain = await $`cat ../../environments/dplplat01/sites.yaml | yq --yaml-fix-merge-anchor-to-spec=true '.sites.${site}.primary-domain'`;

  let response;
  try {
    response = await fetch(`https://${domain}/_metrics/version.json`);
  } catch(error) {
    console.error("error:", error);
  }

  let res;
  try {
    res = await response.json();
  } catch(error) {
    console.log(error);
  }
  console.log(`${res.site}: ${res.imageVersion.tag}`);
}

async function isWebmaster(project) {
   const result = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites.${project}.plan'`;
   return result.stdout === "webmaster\n" ? true : false;
}

