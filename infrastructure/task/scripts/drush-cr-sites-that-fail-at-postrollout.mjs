#!/usr/bin/env zx

// setInterval(runCacheClearSitesThatFailDuringPostRollout, 3600);

const toObjects = (text) => {
  const [head, ...rows] = text.trim().split('\n');
  const keys = head.trim().split(/\s+/).map(k => k.toLowerCase());
  return rows.map(line =>
    Object.fromEntries(line.trim().split(/\s+/).map((v, i) => [keys[i], v]))
  );
};

await runCacheClearSitesThatFailDuringPostRollout();

async function runCacheClearSitesThatFailDuringPostRollout() {
  const lagoonBuildsFailed = await getLagoonBuildsFailedAtPostrollout();
  console.log(lagoonBuildsFailed)
  await runCacheClearOnFailedSites(lagoonBuildsFailed );
}

async function getLagoonBuildsFailedAtPostrollout() {
  const response = await $`kubectl get lagoonbuild -A -l lagoon.sh/buildStatus=Failed`;
  const stdoutBuildsTabel = response.stdout;
  const builds = toObjects(stdoutBuildsTabel);
  console.log(builds)
  return builds.filter(build => build.namespace.includes("dpl-web"))
    .filter(build => build.buildstep == "RunningPostRolloutTasks")
    .filter(build => build.status === "Failed");
}

async function runCacheClearOnFailedSites(failedBuilds) {
  if(failedBuilds.length == 0 ) return;
  for await (const build of failedBuilds) {
    console.log(`clear cache of ${build.namespace}`)
    await $`kubectl exec -it -n ${build.namespace} cli -- drush cr`;
  }
}
