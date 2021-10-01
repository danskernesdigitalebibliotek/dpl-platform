# DPL Admin - a tool for supporting the day-to-day operations

This directory contains a set of scripts that can automate various operational
procedures.

## Deploying a core test site
When to use: when you want to deploy a core release to a test site

Required inputs: the tag for the core release, and the name and branch of the test-environment

### Procedure
``` shell
RELEASE_TAG=<releasetag> SITE=<sitename> BRANCH=<branchname> bin/deploy-release.sh

# Deploying a release
RELEASE_TAG=1.2.3 SITE=core_test1 BRANCH=main task bin/deploy-release.sh

# Doing a diff
DIFF=1 RELEASE_TAG=1.2.3 SITE=core_test1 BRANCH=main task bin/deploy-release.sh

# Default branch is main so it does not have to be specified
RELEASE_TAG=1.2.3 SITE=core_test1 task bin/deploy-release.sh

# Force a deploy in case there is no diff.
FORCE=1 RELEASE_TAG=1.2.3 SITE=core_test1 task bin/deploy-release.sh
```

After a successful run of the script the result will be pushed and Lagoon should
now trigger a deployment if the project i set up to react on webhooks.
