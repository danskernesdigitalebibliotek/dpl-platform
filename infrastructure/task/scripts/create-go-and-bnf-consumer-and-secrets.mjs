#!/usr/bin/env zx
// This script set secrets and consumers for DPL CMS projects. The secrets and consumers are to be identical by secret across all projects.
// source: https://reload.zulipchat.com/#narrow/channel/240325-DDF/topic/Sammenkobling.20af.20DT.20og.20Go.20demo/near/511245805

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

