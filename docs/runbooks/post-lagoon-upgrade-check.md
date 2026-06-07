# Post Lagoon upgrade checklist

This is a checklist to run through post upgrading Lagoon. This is to ensure
that core functionality is intact post the upgrade.

## Prerequisites

There really isen't any besides having had Lagoon upgraded

## Check deployments can be made

1. Run a deployment from [canary-main in the Lagoon UI](https://ui.lagoon.dplplat02.dpl.reload.dk/projects/canary/canary-main/deployments)
2. See that it completes
3. Make a change to .lagoon.yaml in [customizable-canary-main's env repo](https://github.com/danishpubliclibraries/env-customizable-canary/edit/main/.lagoon.yml)
 this should be something small and insignificant like change a cron jobs
schedule by a minute.
4. Go to [customizable-canary-main](https://ui.lagoon.dplplat02.dpl.reload.dk/projects/customizable-canary/customizable-canary-main/deployments)
and see that it both runs and completes.
5. Open the DPL platform project. Find .lagoon.yaml and edit the change the
schedule back. Run `SITE=customizable-canary task site:sync` and check that
it started a deployment. See it through.

## Check tasks

Go to [canary-main's tasks](https://ui.lagoon.dplplat02.dpl.reload.dk/projects/canary/canary-main/tasks)
 and select "Generate login link". Open the task and see that it works.
 
