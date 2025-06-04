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
  echo(`setting env variables for ${project}`);
  for (const variableName of lagoonVariableName) {
    const secret = crypto.randomBytes(64).toString("base64");
    try {
      await $`lagoon add variable --project ${project} --name ${variableName} --scope global --value ${secret}`;
    } catch (error) {
      throw Error("failed to create or update variables for BNF and GO secrets", { cause: error });
    }
  }
}

for await (const site of sites) {
  await setVariablesForProject(site);
}

echo("done");
echo("")
