#!/usr/bin/env zx

echo(chalk.yellow("Will now reconfigure MariaDBConsumers"));
echo("");

const sites = await $`cat ../../../host_mount/environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`;

