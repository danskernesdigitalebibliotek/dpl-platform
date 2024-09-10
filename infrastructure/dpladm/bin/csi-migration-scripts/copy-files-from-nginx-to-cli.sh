#!/usr/bin/env bash
#
# Start a KK Shell session
#
# Syntax:
#  dplsh [-p profile-name] [additional shell args]
#
set -euo pipefail

NAMESPACES=$(kubectl get ns -l lagoon.sh/controller=lagoon --no-headers | awk '{print $1}' | grep herning)

for ns in $NAMESPACES; do
  echo $ns
  NGINX=$(kubectl get pod -n $ns -l lagoon.sh/service=nginx -o name | head -n1)
  CLI=$(kubectl get pod -n $ns -l lagoon.sh/service=cli --no-headers | grep -v cronjob | grep Running | awk '{print $1}')
  kubectl exec -n $ns $NGINX -- tar cf - /app/web/sites/default/files | kubectl exec -i -n $ns $CLI  -- tar xvfk - -C / || true
done
