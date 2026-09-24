#!/usr/bin/env zx

const sites =
  await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites | ... comments="" | keys | .[]'`

// These sites was setup differently than the production sites.
for await (const site of sites.lines()) {
  await $`lagoon ssh -p ${site} -e 'main' -C "drush cr"`
  if (await isWebmaster(site)) {
    await $`lagoon ssh -p ${site} -e 'moduletest' -C "drush cr"`
  }
}

async function isWebmaster(project) {
  const result = await $`cat ../../environments/dplplat01/sites.yaml | yq '.sites.${project}.plan'`
  return result.stdout === "webmaster\n" ? true : false
}
