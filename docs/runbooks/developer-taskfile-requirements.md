# Tooling requirements for developers

## Who is this for

This doc is for developers with elevated access. This doc describes the tooling
needed to be able to do operationel adjecent tasks via the dpl-platform project.

## Required CLI tooling

To be able to use all scripts and tasks in dpl-platform you will need the
the following tools installed on your machine:

- yq: https://mikefarah.gitbook.io/yq/
- jq: https://jqlang.org/
- taskfile: https://taskfile.dev/docs/installation

## Secrets and access

As a new user of the platform projekt, you will need access to the .env file.
This file can be found in Reloads OnePass vault.

The file should be put in /infrastructure/.env and looks like this:

´´
# Default environment-variables that should exist across all environments.
AZURE_SUBSCRIPTION_ID=value
AZURE_KEYVAULT_NAME=value
AZURE_RESOURCE_GROUP_NAME=value
DPLPLAT_ENV=value
CLUSTER_NAME=value
DNSIMPLE_ACCOUNT=value
GITHUB_TOKEN=value
AZURE_MAIL_CONNECTION_STRING=value
SSH_HOSTNAME=value``
