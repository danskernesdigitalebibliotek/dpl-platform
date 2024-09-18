#!/usr/bin/env bash
#
# Lagoon doesn't allow us to set tolerations on our workloads, so we set them
# manually with this script. During adoption of the production-only nodes, we
# can gradually promote workloads to the production nodes by adding them to the
# below list of namespaces.

PROMOTED_NAMESPACES=(
  "aabenraa-main"
  "aalborg-main"
  "aalborg-moduletest"
  "aarhus-main"
  "aarhus-moduletest"
  "aero-main"
  "albertslund-main"
  "albertslund-moduletest"
  "allerod-main"
  "assens-main"
  "ballerup-main"
  "ballerup-moduletest"
  "bibliotek-test-main"
  "bibliotek-test-moduletest"
  "billund-main"
  "bornholm-main"
  "brondby-main"
  "bronderslev-main"
  "canary-main"
  "canary-moduletest"
  "cms-school-main"
  "cms-school-moduletest"
  "customizable-canary-main"
  "customizable-canary-moduletest"
  "dragor-main"
  "egedal-main"
  "esbjerg-main"
  "faaborg-midtfyn-main"
  "favrskov-main"
  "faxe-main"
  "faxe-moduletest"
  "fredensborg-main"
  "fredericia-main"
  "frederiksberg-main"
  "frederikshavn-main"
  "frederikssund-main"
  "fureso-main"
  "gentofte-main"
  "gladsaxe-main"
  "glostrup-main"
  "greve-main"
  "gribskov-main"
  "guldborgsund-main"
  "haderslev-main"
  "halsnaes-main"
  "hedensted-main"
  "helsingor-main"
  "herlev-main"
  "herning-main"
  "herning-moduletest"
  "hillerod-main"
  "hjorring-main"
  "hoje-taastrup-main"
  "holbaek-main"
  "holstebro-main"
  "horsens-main"
  "horsholm-main"
  "hvidovre-main"
  "ikast-brande-main"
  "ishoj-main"
  "jammerbugt-main"
  "kalundborg-main"
  "kerteminde-main"
  "kobenhavn-main"
  "kobenhavn-moduletest"
  "koge-main"
  "kolding-main"
  "laeso-main"
  "langeland-main"
  "lejre-main"
  "lolland-main"
  "lyngby-taarbaek-main"
  "mariagerfjord-main"
  "middelfart-main"
  "morso-main"
  "naestved-main"
  "norddjurs-main"
  "nordfyn-main"
  "nyborg-main"
  "odder-main"
  "odense-main"
  "odense-moduletest"
  "odsherred-main"
  "randers-main"
  "rebild-main"
  "ringkobing-skjern-main"
  "ringsted-main"
  "rodovre-main"
  "roskilde-main"
  # "roskilde-moduletest"
  # "rudersdal-main"
  # "samso-main"
  # "silkeborg-main"
  # "silkeborg-moduletest"
  # "skanderborg-main"
  # "skive-main"
  # "solrod-main"
  # "sonderborg-main"
  # "sonderborg-moduletest"
  # "soro-main"
  # "staging-main"
  # "staging-moduletest"
  # "stevns-main"
  # "struer-main"
  # "svendborg-main"
  # "syddjurs-main"
  # "sydslesvig-main"
  # "sydslesvig-moduletest"
  # "taarnby-main"
  # "taarnby-moduletest"
  # "thisted-main"
  # "vallensbaek-main"
  # "varde-main"
  # "vejen-main"
  # "vejle-main"
  # "vesthimmerland-main"
  # "viborg-main"
  # "vordingborg-main"
)

DEPLOYMENTS=("cli" "nginx" "varnish" "redis")

NAMESPACES_RAW=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
# shellcheck disable=SC2206
NAMESPACES=($NAMESPACES_RAW)

echo "Patching tolerations on all promoted namespace workloads to schedule on production nodes"
for NS in "${NAMESPACES[@]}"; do

  # Only patch promoted namespaces
  if [[ " ${PROMOTED_NAMESPACES[*]} " =~ ${NS} ]]; then
    echo "## Namespace: $NS"

    for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
      kubectl patch deployments.apps -n "$NS" "$DEPLOYMENT" -p '{
        "spec": {
          "template": {
            "spec": {
              "tolerations": [
                {
                  "key": "noderole.dplplatform",
                  "operator": "Equal",
                  "value": "prod",
                  "effect": "NoSchedule"
                }
              ],
              "affinity": {
                "nodeAffinity": {
                  "requiredDuringSchedulingIgnoredDuringExecution": {
                    "nodeSelectorTerms": [
                      {
                        "matchExpressions": [
                          {
                            "key": "noderole.dplplatform",
                            "operator": "In",
                            "values": [ "prod" ]
                          }
                        ]
                      }
                    ]
                  }
                }
              }
            }
          }
        }
      }'
    done
  fi
done
