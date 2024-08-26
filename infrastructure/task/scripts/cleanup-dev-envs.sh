#!/usr/bin/env bash
#
# Cleanup development environments in our core Lagoon project.
#
# With our setup Lagoon creates a development environment automatically each
# time a pull request is created. Such an environments should also be deleted
# when the pull request is closed. This is usually the case when the PR is
# merged but often failed when the pull request is closed without merging.
#
# To work around this issue this script tries to close all development
# environments in Lagoon where the corresponding pull request has been either
# closed or merged.

LAGOON_PROJECT="dpl-cms"
REPO="danskernesdigitalebibliotek/dpl-cms"

DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
fi

DEV_ENVS=$(lagoon raw --raw "query dplCmsEnvs {
  projectByName(name: \"$LAGOON_PROJECT\") {
    environments {
      name
      environmentType
    }
  }
}" | jq -c '.projectByName.environments[] | select(.environmentType == "development" and .name != "develop")')

echo "$DEV_ENVS" | while read -r environment; do
  ENV_NAME=$(echo "$environment" | jq -r '.name')
  # Lagoon development environments are named after the number of their
  # corresponding pull request.
  PR_NUMBER=$(echo "$environment" | jq -r '.name | gsub("^pr-"; "") | tonumber')

  # Check the status of the PR using the gh CLI
  PR_STATUS=$(gh pr view "$PR_NUMBER" --repo $REPO --json state -q '.state')

  if [[ "$PR_STATUS" == "CLOSED" || "$PR_STATUS" == "MERGED" ]]; then

    echo "PR #$PR_NUMBER is $PR_STATUS. Closing development environment: $ENV_NAME."

    if [ "$DRY_RUN" = true ]; then
      echo "Dry-run: lagoon delete environment -p \"$LAGOON_PROJECT\" -e \"$ENV_NAME\""
    else
      echo "foo"
      #lagoon delete environment -p "$LAGOON_PROJECT" -e "$ENV_NAME"
    fi
  fi
done;