# Deploy new version to library site(s)

## When to use

If you want to deploy a new version of `dpl-cms` to [one or more library sites
which have been added to the platform](add-library-site-to-platform.md).

## Prerequisites

* A local checkout of the [`dpl-platform` repository](https://github.com/danskernesdigitalebibliotek/dpl-platform)
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
* The version tag you want to deploy. This must correspond to a
  tagged version of the [`dpl-cms-source` image](https://github.com/danskernesdigitalebibliotek/dpl-cms/pkgs/container/dpl-cms-source).

## Procedure: New version for testing

Use this procedure to deploy a new version for testing before it is released to
production library sites.

1. In your local environment ensure that your checkout of the `main` branch for
   `dpl-platform` is up to date.
2. Create a new branch from `main`.
3. Open `infrastructure/environments/dplplat01/sites.yaml`, find `staging`,
   then update the value of `dpl-cms-release` for `staging` to the version
4. Commit the change and push your branch to GitHub and create a pull request.
5. Request a review for the change and wait for approval.
6. Start `dplsh` from the `/infrastructure` directory of your local
   environment by running `../tools/dplsh/dplsh.sh`.
7. Run `SITE=staging task sites:sync` to deploy the changes.
8. Open the deployment section for the `staging` project in the Lagoon UI.
9. Wait for the deployment to complete.
10. If the deployment does not complete determine if the error relates to the
    platform or the application.
11. If it is a platform-related error then try to redeploy the environment from
    the Lagoon UI.
12. Merge the pull request once the deployment completes.

## Procedure: New version to library sites

1. In your local environment ensure that your checkout of the `main` branch for
   `dpl-platform` is up to date.
2. Create a new branch from `main`.
3. Update `infrastructure/environments/dplplat01/sites.yaml` by setting the
   value for `dpl-cms-release` and `moduletest-dpl-cms-release` for [appropriate
   anchors](#deploy-to-a-subset-of-sites).
4. Commit the change and push your branch to GitHub and create a pull request.
5. Request a review for the change and wait for approval.
6. Start `dplsh` from the `/infrastructure` directory of your local
   environment by running `../tools/dplsh/dplsh.sh`
7. Run `task sites:sync` from `dplsh` to deploy the changes.
8. If there are any Terraform changes then do not apply them, abort the
   deployment and consult the platform team.
9. Open the Deployments list page within the Lagoon UI to see all running and
   queued deployments.
10. Wait for all the deployment to complete.
11. Run `task sites:incomplete-deployments` to identify any failed deployments.
12. If some deployments do not complete determine if the error relates to the
    platform or the application.
13. For all platform-related errors then try to redeploy the environment from
    the Lagoon UI.
14. Merge the pull request once the deployment completes.
15. Run `task cluster:adjust:resource-request` from `dplsh`.
16. Run `task cluster:promote-workloads-to-prod` from `dplsh`.

## Deploy to a subset of sites

When deploying a new version you will usually deploy it to a subset of all
the available sites and environments. The commonly used subsets correspond to a
list of available anchors within `sites.yaml`:

Production environments for editor sites (and a select few webmaster sites)
: Update `dpl-cms-release` for `&default-release-image-source`

Moduletest environments for webmaster sites
: Update `moduletest-dpl-cms-release` for `&webmaster-release-image-source`

Production environments for webmaster sites
: Update `dpl-cms-release` for `&webmaster-release-image-source`

## Troubleshooting

During the deployment process you may encounter problems. This is a list of
known problems and how to address them.

If a problem is not mentioned explicitly it should be raised to team which is
most likely responsible:

* All deployment steps prefixed with *Post-Rollout*: Application developers
* All other errors: Platform administrators

### Platform-related errors

A Lagoon deployment can end up with a *Failed* status. If this is the case then
the following errors may show up in the log output shown for the deployment in
the Lagoon UI.

#### TLS handshake timeout

If the log output of a deployment contains the following during various stages
of the deployment then redeploy the environment from the Lagoon UI:

`Unable to connect to the server: net/http: TLS handshake timeout`

This may be caused by a spike in load during deployment.

#### Context deadline exceeded

If the log output of a deployment contains the following then redeploy the
environment from the Lagoon UI:

`failed to call webhook: Post "[Ingress url]": context deadline exceeded`

This may be caused by a spike in load during deployment.

#### Harbor authentication failed

If log output for the deployment contains the following during the *Image Push
to Registry* stage of the deployment then redeploy the environment from the
Lagoon UI:

`level=fatal msg="copying system image from manifest list: trying to reuse blob
sha256:[SHA] at destination: checking whether a blob sha256:[SHA] exists in
[Harbor url]: authentication required"`

This is caused by [a bug in Harbor](https://github.com/goharbor/harbor/issues/18971).
It should be addressed in a future update of this part of the platform.

#### MySQL server has gone away

If log output for the deployment contains the following during the *Post-Rollout
drush deploy* stage of the deployment then redeploy the environment from the
Lagoon UI:

`Drupal\Core\Database\DatabaseExceptionWrapper: SQLSTATE[HY000]: General error: 
2006 MySQL server has gone away`

This may be caused by intermittent database problems caused by spike in load
during deployments.
