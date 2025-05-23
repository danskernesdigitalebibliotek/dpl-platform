#!/usr/bin/env zx
// This script set variables with secrets for the node service to use

import * as crypto from "crypto";

echo("Creating og updating node service reliant variables for all environments");
echo("");
const sites = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

const lagoonVariableName = [
  "GO_SESSION_SECRET",
];

async function setVariablesForProject(project, environment = "main") {
  for (const variableName of lagoonVariableName) {
    const secret = crypto.randomBytes(64).toString("base64");
    try {
      await $`lagoon add variable --project ${project} --environment ${environment} --name ${variableName} --scope global --value ${secret}`;
    } catch (error) {
      throw Error("failed to create or update variables for BNF and GO secrets", { cause: error });
    }
  }
}

async function isWebmaster(project) {
   const result = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites.${project}.plan'`;
   return result.stdout === "webmaster\n" ? true : false;
}

for await (const site of sites) {
  await setVariablesForProject(site);
  if (await isWebmaster(site)) {
  // Also set it for the moduletest project
    setVariablesForProject(site, "moduletest");
  }
}

echo("done");
echo("")
