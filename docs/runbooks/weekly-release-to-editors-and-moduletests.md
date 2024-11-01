# Deploy new version to editors and webmaster moduletests

## When to use

When doing a regular weekly release where the goal is to deploy the
new release to editors and the moduletest environments of webmasters, but not
the production environments of webmasters.

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
3. Now update `infrastructure/environments/dplplat01/sites.yaml`.
    The 'x-defaults' anchors' 'dpl-cms-release' tag should be bumped to the
    new version. Then update the 'moduletest-dpl-cms-release' of 'x-webmaster'
    to the same version. Update the same property for the
    'x-webmaster-with-defaults' anchor.
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
11. Wait for all the deployment to complete.
12. Run `task sites:incomplete-deployments` to identify any failed deployments.
13. If some deployments did not complete determine if the error relates to the
    platform or the application.
14. For all platform-related errors try to redeploy the environment from
    the Lagoon UI.
15. Merge the pull request once the deployment completes.
16. Run `task cluster:adjust:resource-request` from `dplsh`.
17. Run `task cluster:promote-workloads-to-prod` from `dplsh`.
18. Run 'task cluster:mode:reset' from `dplsh`.

## Procedure: a some sites fails to deploy

We have experience this quite a lot. We have gathered a list of known
issues and how to solve them a troubleshoot [runbook](troubleshoot-release-deployment.md)
