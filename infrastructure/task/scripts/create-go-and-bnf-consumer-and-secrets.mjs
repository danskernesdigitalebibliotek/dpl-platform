#!/usr/bin/env zx
// This script set secrets and consumers for DPL CMS projects. The secrets and consumers are to be identical by secret across all projects.
// source: https://reload.zulipchat.com/#narrow/channel/240325-DDF/topic/Sammenkobling.20af.20DT.20og.20Go.20demo/near/511245805

import * as crypto from "crypto";

echo("Setting BNF and GO consumer secrets and passwords on all environments across projects");
echo("");
const sites = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

const lagoonVariableName = [
  "BNF_GRAPHQL_CONSUMER_SECRET",
  "BNF_GRAPHQL_CONSUMER_USER_PASSWORD",
  "BNF_SERVER_GRAPHQL_ENDPOINT",
  "GO_GRAPHQL_CONSUMER_SECRET",
  "GO_GRAPHQL_CONSUMER_USER_PASSWORD"
];

const lagoonVariableValues = lagoonVariableName.map((_, i) => crypto.randomBytes(64).toString("base64"));

async function setVariablesForProject(project, environment = "main") {
  for (const [index, value] of lagoonVariableName.entries()) {
    try {
      await $`lagoon add variable --project ${project} --environment ${environment} --name ${value} --scope global --value ${lagoonVariableValues[index]}`;
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
