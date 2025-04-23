#!/usr/bin/env zx
// This script set variables with secrets for the node service to use

echo("Creating og updating node service reliant variables for all environments");
echo("");
const sites = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

const lagoonVariableName = [
  "GO_SESSION_SECRET",
  "NEXT_PUBLIC_GRAPHQL_BASIC_TOKEN_DPL_CMS",
  "NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_DPL_CMS",
  "NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_FBI",
  "UNILOGIN_CLIENT_ID",
  "UNILOGIN_CLIENT_SECRET",
  "UNILOGIN_MUNICIPALITY_ID",
  "UNILOGIN_WELLKNOWN_URL",
  "UNLILOGIN_PUBHUB_CLIENT_ID",
  "UNLILOGIN_PUBHUB_RETAILER_ID",
  "UNLILOGIN_PUBHUB_RETAILER_KEY_CODE",
  "UNLILOGIN_SERVICES_WS_PASSWORD",
  "UNLILOGIN_SERVICES_WS_USER"
];


for await (const site of sites) {
  await setVariablesForProject(site);
  if (await isWebmaster(site)) {
  // Also set it for the moduletest project
    setVariablesForProject(site, "moduletest");
  }
}

