#!/usr/bin/env zx

const namespaces = [
  "aabenraa-main",
  "aalborg-main",
  "aalborg-moduletest",
  "aarhus-main",
  "aarhus-moduletest",
  "aero-main",
  "albertslund-main",
  "albertslund-moduletest",
  "allerod-main",
  "assens-main",
  "ballerup-main",
  "ballerup-moduletest",
  "billund-main",
  "bnf-main",
  "bnf-moduletest",
  "bornholm-main",
  "brondby-main",
  "bronderslev-main",
  "cms-school-main",
  "cms-school-moduletest",
  "customizable-canary-main",
  "customizable-canary-moduletest",
  "dragor-main",
  "egedal-main",
  "esbjerg-main",
  "faaborg-midtfyn-main",
  "favrskov-main",
  "faxe-main",
  "faxe-moduletest",
  "fredensborg-main",
  "fredericia-main",
  "frederiksberg-main",
  "frederikshavn-main",
  "frederikssund-main",
  "fureso-main",
  "gentofte-main",
  "gladsaxe-main",
  "glostrup-main",
  "greve-main",
  "gribskov-main",
  "guldborgsund-main",
  "haderslev-main",
  "halsnaes-main",
  "hedensted-main",
  "helsingor-main",
  "herlev-main",
  "herning-main",
  "herning-moduletest",
  "hillerod-main",
  "hjorring-main",
  "hoje-taastrup-main",
  "holbaek-main",
  "holstebro-main",
  "horsens-main",
  "horsholm-main",
  "hvidovre-main",
  "ikast-brande-main",
  "ishoj-main",
  "kalundborg-main",
  "kerteminde-main",
  "kobenhavn-main",
  "kobenhavn-moduletest",
  "koge-main",
  "kolding-main",
  "laeso-main",
  "langeland-main",
  "lejre-main",
  "lolland-main",
  "lyngby-taarbaek-main",
  "mariagerfjord-main",
  "middelfart-main",
  "morso-main",
  "naestved-main",
  "norddjurs-main",
  "nordfyn-main",
  "nyborg-main",
  "odder-main",
  "odense-main",
  "odense-moduletest",
  "odsherred-main",
  "randers-main",
  "rebild-main",
  "ringkobing-skjern-main",
  "ringsted-main",
  "rodovre-main",
  "roskilde-main",
  "roskilde-moduletest",
  "rudersdal-main",
  "samso-main",
  "silkeborg-main",
  "silkeborg-moduletest",
  "skanderborg-main",
  "skive-main",
  "solrod2-main",
  "sonderborg-main",
  "sonderborg-moduletest",
  "soro-main",
  "stevns-main",
  "struer-main",
  "svendborg-main",
  "syddjurs-main",
  "sydslesvig-main",
  "sydslesvig-moduletest",
  "taarnby-main",
  "taarnby-moduletest",
  "thisted-main",
  "torshavn-main",
  "vallensbaek-main",
  "varde-main",
  "vejen-main",
  "vejle-main",
  "vesthimmerland-main",
  "viborg-main",
  "vordingborg-main"
];

for await (const namespace of namespaces ) {
  await extactSecretFromOldCluster(namespace);
  await kubesealSecretWithNewClustersCert(namespace);
  await removeUnsealedDatabaseSecret(namespace);
}

async function extactSecretFromOldCluster(namespace) {
  await $`kubectl config use-context aks-dplplat01-01`;
  try {
    await $`kubectl get secret database-secret -n ${namespace} -o json | jq '.stringData = (.data | with_entries(.value |= @base64d)) | del(.data) | del(.metadata.ownerReferences) | del(.metadata.creationTimestamp) | del(.metadata.resourceVersion) | del(.metadata.uid)' | yq -P > ${namespace}/templates/database-secret.yaml`;
  } catch(error) {
    console.error(`failed to extract database-secret from ${namespace}, this could be because the secret is named something else:`, error);
  }
}

async function kubesealSecretWithNewClustersCert(namespace) {
  await $`kubectl config use-context dplplat02`;
  try {
    await $`kubeseal -o yaml --secret-file ${namespace}/templates/database-secret.yaml > ${namespace}/templates/sealed-database-secret.yaml`;
  } catch(error) {
    console.error(`could not 'kubeseal' database-secret in ${namespace}, this might be due to the secret having another name and thus, not having been moved:`, error);
  }
}

async function removeUnsealedDatabaseSecret(namespace) {
  try {
    await $`rm ${namespace}/templates/database-secret.yaml`;
  } catch(error) {
    throw Error(`failed to delete database-secret.yaml in /${namespace}/templates`);
  }
}

