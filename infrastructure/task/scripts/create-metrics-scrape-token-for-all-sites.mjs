#!/usr/bin/env zx
// This script set secrets and consumers for DPL CMS projects. The secrets and consumers are to be identical by secret across all projects.
// source: https://reload.zulipchat.com/#narrow/channel/240325-DDF/topic/Sammenkobling.20af.20DT.20og.20Go.20demo/near/511245805

import * as crypto from "crypto"

echo("Setting METRICS_SCRAPER_TOKEN on all environments across projects")
echo("")
const sites =
  await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`

const lagoonVariableName = [
  "METRICS_SCRAPE_TOKEN",
]

async function setVariablesForProject(secret, project, environment = "main") {
  echo(`setting env variables for ${project}-${environment}`)
  for (const [index, value] of lagoonVariableName.entries()) {
    try {
      await $`lagoon update variable --project ${project} --environment ${environment} --name METRICS_SCRAPE_TOKEN --scope global --value ${secret}`
    } catch (error) {
      throw Error(`failed to create or update METRICS_SCRAPE_TOKEN secret for project ${project} environment ${environment}`, { cause: error })
    }
  }
}

async function isWebmaster(project) {
  const result = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites.${project}.plan'`
  return result.stdout === "webmaster\n";
}


for await (const site of sites.lines()) {
  const secret = crypto.randomBytes(64).toString("base64");
  if(await isWebmaster(site)) {
    const secret = crypto.randomBytes(64).toString("base64");
    await setVariablesForProject(secret, site, "moduletest")
  }
  await setVariablesForProject(secret, site)
}

echo("done")
