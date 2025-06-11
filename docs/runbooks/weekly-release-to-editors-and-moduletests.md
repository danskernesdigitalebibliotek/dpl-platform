# Deploy new version to editors and webmaster moduletests

## When to use

When doing a regular release, where editors and webmaster moduletest sites are
updated to latest release, and webmaster production is updated to second latest
release.

## Prerequisites

* A local checkout of the [`dpl-platform` repository](https://github.com/danskernesdigitalebibliotek/dpl-platform)
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* The version tag you want to deploy. This must correspond to a
  tagged version of the [`dpl-cms-source` image](https://github.com/danskernesdigitalebibliotek/dpl-cms/pkgs/container/dpl-cms-source).
* The second latest version

## Procedure: Make the release Pull Request

1. In your local environment ensure that your checkout of the `main`
   branch for `dpl-platform` is up to date, by doing a `git pull origin main`.
2. Create a new branch from `main`.
3. Now update `infrastructure/environments/dplplat01/sites.yaml`. The
    `x-defaults` anchors' `dpl-cms-release` tag should be bumped to
    the latest version. Then update the `moduletest-dpl-cms-release` of
    `x-webmasters-on-weekly-release-cycle` to the same version. Now update
    `dpl-cms-release` of `x-webmasters-on-weekly-release-cycle` to the second
    latest release. Lastly update cms-school's, the canary sites' and
    bibliotek-test's to the lastest release for both moduletest and production.
4. Commit the change and push your branch to GitHub and create a pull
   request.
5. Request a review for the change and wait for approval.

## Procedure: Release the approved release

1. Merge the approved Pull Request and pull your local main branch to match.
2. Start `dplsh` from the `/infrastructure` directory of your local
   environment by running `../tools/dplsh/dplsh.sh`
3. Run `task sites:sync` from `dplsh` to deploy the changes.
4. If there are any Terraform changes then do not apply them, abort
   the deployment and consult the platform team.
5. Open the Deployments list page within the Lagoon UI to see all
   running and queued deployments.
6. Wait for all the deployment to complete.
7. Run `sites:redeploy-failed-deployments` to identify and redeploy any failed
    deployments.
8. If some deployments did not complete determine if the error
    relates to the platform or the application.
9. For all platform-related errors try to redeploy the environment
    from the Lagoon UI.
10. Run `task cluster:promote-workloads-to-prod` from `dplsh`.
11. The moduletest sites should now be reset so their state matches their
    production counter parts. This is done by running the synchonization tasks
    in the Lagoon UI for each moduletest site.

## Procedure: a some sites fails to deploy

We have experience this quite a lot. We have gathered a list of known
issues and how to solve them a troubleshoot [runbook](troubleshoot-release-deployment.md)
