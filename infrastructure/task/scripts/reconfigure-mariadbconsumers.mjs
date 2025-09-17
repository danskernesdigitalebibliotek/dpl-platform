#!/usr/bin/env zx

echo(chalk.yellow("Will now reconfigure MariaDBConsumers"));
echo("");

const sites = await $`cat ../../../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

// These sites was setup differently than the production sites.
const blackList = [
  "customizable-canary",
  "staging",
  "canary",
  "staging",
  "bibliotek-test"
];

