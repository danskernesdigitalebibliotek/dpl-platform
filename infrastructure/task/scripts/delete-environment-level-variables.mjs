#!/usr/bin/env zx

echo(chalk.yellow("Deleting environment level environment variables"));
echo("");
const sites = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

const lagoonVariableNames = [
  "BNF_GRAPHQL_CONSUMER_SECRET",
  "BNF_GRAPHQL_CONSUMER_USER_PASSWORD",
  "GO_GRAPHQL_CONSUMER_SECRET",
  "DRUPAL_REVALIDATE_SECRET",
  "NEXT_PUBLIC_GO_GRAPHQL_CONSUMER_USER_PASSWORD",
  "GO_SESSION_SECRET"
];

async function deleteEnvironmentVariables(project, environment = "main") {
  echo(`deleting env variables for ${project}-${environment}`);
  for (const variableName of lagoonVariableNames) {
    try {
      await $`lagoon delete variable --project ${project} --environment ${environment} --name ${variableName} --force`;
    } catch (error) {
      throw Error("failed to delete variables for BNF and GO secrets", { cause: error });
    }
  }
}

