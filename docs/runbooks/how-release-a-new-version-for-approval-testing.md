# Deploy new release for approval testing

## When to use

When deploying a new release, for approval testing by DDF, on the staging project

## Prerequisites

* A local checkout of the [`dpl-platform` repository](https://github.com/danskernesdigitalebibliotek/dpl-platform)
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* The version tag you want to deploy. This must correspond to a
  tagged version of the [`dpl-cms-source` image](https://github.com/danskernesdigitalebibliotek/dpl-cms/pkgs/container/dpl-cms-source).
* The version tag of Go that you want to deploy. The version generally
  follows the cms version unless a hotfix is being released.

## Procedure: New release for approval testing

Use this procedure to deploy a new version for testing before it is released to
production library sites.

1. In your local environment ensure that your checkout of the `main` branch for
   `dpl-platform` is up to date.
2. Create a new branch from `main`.
3. Open `infrastructure/environments/dplplat01/sites.yaml`
   1. Set the value of `dpl-cms-release` and `moduletest-dpl-cms-release` for
      `staging` to the new version
   2. Set the value of `moduletest-dpl-cms-release` for `bnf` to the new version
   3. Set the value of `go-release` for to the new version.
4. Commit the change and push your branch to GitHub and create a pull request.
5. Request a review for the change and wait for approval.
6. Start `dplsh` from the `/infrastructure` directory of your local
   environment by running `../tools/dplsh/dplsh.sh`.
7. Deploy the changes
   1. Run `SITE=staging task site:sync`
   2. Run `SITE=bnf task site:sync`
8. Wait for the deployments for `staging` and `bnf` to complete using Lagoon UI
9. If a deployment does not complete determine if the error relates to the
   platform or the application.
10. If it is a platform-related error then try to redeploy the environment from
    the Lagoon UI.
11. Merge the pull request once the deployment completes.

## Procedure: A site fails to deploy

We have experience this quite a lot. We have gathered a list of known
issues and how to solve them a troubleshoot [runbook](troubleshoot-release-deployment.md)
