#!/usr/bin/env zx

echo(chalk.yellow("Deleting environment level environment variables"));
echo("");
const sites = await $`cat ../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

