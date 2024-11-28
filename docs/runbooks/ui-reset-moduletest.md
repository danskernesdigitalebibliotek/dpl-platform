# UI: Reset moduletest site

## When to use

When a moduletest site need resetting

**Warning:** This procedure does not sync the site properly, as it
doesn't delete files/tables that exists on moduletest but not in
production. In many cases, this isn't a problem, but i some instances
it could be. If in doubt, ask a platform engineer to do the sync.

## Procedure

1. Find the moduletest site of the project that need resetting in the Lagoon UI
2. Go to tasks
3. Select "Copy files between environments", and set the source
  to "main" and run the task. This queues the task and lagoon will run it when
  it can.
  There's some role/user restrictions in place by lagoon, which
  makes the task fail, as it can't set the correct time on the files. If that
  is the only
  error, then it copied the files, and this step is done. Otherwise run it again
4. Select "Copy database between environments", and set the source
  to "main" and run the task
5. Go to deployments and pres "deploy", this ensures that the state matches that
  of the environment.
6. Go the page URL and check that it looks alright

The moduletest site is now reset
