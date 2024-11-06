# Monthly release to editors and webmasters

## When to use

The last thursday of the month we deploy as usual as well as
to the webmasters production environments as well. It is very important
to note here. The webmaster production environments will have the latest
release - 1. This usually mean last weeks release.

## Prerequisites

* A local checkout of the [`dpl-platform` repository](https://github.com/danskernesdigitalebibliotek/dpl-platform)
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* The version tag you want to deploy. This must correspond to a
  tagged version of the [`dpl-cms-source` image](https://github.com/danskernesdigitalebibliotek/dpl-cms/pkgs/container/dpl-cms-source).

## Procedure: New version to editors and moduletest environments

1. In your local environment ensure that your checkout of the `main` branch for
   `dpl-platform` is up to date.
2. Create a new branch from `main`.
3. Now update `infrastructure/environments/dplplat01/sites.yaml`:
    1. The 'x-defaults' anchors' 'dpl-cms-release' tag should be bumped to the
    new version.
    2. Then update the 'moduletest-dpl-cms-release' of 'x-webmaster'
    and 'x-webmaster-with-defaults' anchor.
    3. Now update 'dpl-cms-release' of the 'x-webmaster' anchor to the penultimate
    version of the cms.
4. Commit the change and push your branch to GitHub and create a pull request.
5. Request a review for the change and wait for approval.
6. Start `dplsh` from the `/infrastructure` directory of your local
   environment by running `../tools/dplsh/dplsh.sh`
7. Run `task cluster:mode:release` to get more nodes while deploying.
8. Run `task sites:sync` from `dplsh` to deploy the changes.
9. If there are any Terraform changes then do not apply them, abort the
   deployment and consult the platform team.
10. Open the Deployments list page within the Lagoon UI to see all running and
   queued deployments.
11. Wait for all the deployments to complete.
12. Run `task sites:incomplete-deployments` to identify any failed deployments.
13. If some deployments did not complete determine if the error relates to the
    platform or the application.
14. For all platform-related errors try to redeploy the environment from
    the Lagoon UI.
15. Merge the pull request once the deployment completes.
16. Run `task cluster:adjust:resource-request` from `dplsh`.
17. Run `task cluster:promote-workloads-to-prod` from `dplsh`.
18. Synchronize moduletest with main, so moduletest becomes an exact
    copy of main by running `task sites:webmaster:reset-moduletest`.
19. Run 'task cluster:mode:reset' from `dplsh`.

## Procedure: a some sites fails to deploy

We have experience this quite a lot. We have gathered a list of known
issues and how to solve them a troubleshoot [runbook](troubleshoot-release-deployment.md)
