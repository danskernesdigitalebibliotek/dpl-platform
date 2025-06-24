# Add a new library site to the platform

## When to use

When you want to add a new core-test, editor, webmaster or programmer dpl-cms
site to the platform.

## Prerequisites

* An authenticated `az` cli. The logged in user must have full administrative
  permissions to the platforms azure infrastructure.
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.

## Procedure

The following sections describes how to

* Add the site to `sites.yaml`
* Using the `sites.yaml` specification to provision Github repositories,
  create Lagoon projects, tie the two together, and deploy all the
  relevant environments.

### Step 1, update sites.yaml

Create an entry for the site in `sites.yaml`.

Specify a unique site key (its key in the map of sites), name and description.
Leave out the deployment-key, it will be added automatically by the
synchronization script.

Sample entry (beware that this example be out of sync with the environment you
are operating, so make sure to compare it with existing entries from the
environment)

```yaml
sites:
  bib-rb:
    name: "Roskilde Bibliotek"
    description: "Roskilde Bibliotek"
    primary-domain: "www.roskildebib.dk"
    secondary-domains: ["roskildebib.dk"]
    dpl-cms-release: "1.2.3"
    go-release: "1.2.3"
    << : *default-release-image-source
```

The last entry merges in a default set of properties for the source of release-
images. If the site is on the "programmer" plan, specify a custom set of
properties like so:

```yaml
sites:
  bib-rb:
    name: "Roskilde Bibliotek"
    description: "Roskilde Bibliotek"
    primary-domain: "www.roskildebib.dk"
    secondary-domains: ["roskildebib.dk"]
    dpl-cms-release: "1.2.3"
    go-release: "1.2.3"
    # Github package registry used as an example here, but any registry will
    # work.
    releaseImageRepository: ghcr.io/some-github-org
    releaseImageName: some-image-name
```

Be aware that the referenced images needs to be publicly available as Lagoon
currently only authenticates against ghcr.io.

Sites on the "webmaster" plan must have the field `plan` set to `"webmaster"`
as this indicates that an environment for testing custom Drupal modules should
also be deployed. For example:

```yaml
sites:
  bib-rb:
    name: "Roskilde Bibliotek"
    description: "Roskilde Bibliotek"
    primary-domain: "www.roskildebib.dk"
    secondary-domains: ["roskildebib.dk"]
    dpl-cms-release: "1.2.3"
    go-release: "1.2.3"
    plan: webmaster
    << : *default-release-image-source
```

The field `plan` defaults to `standard`.

Now you are ready to sync the site state.

### Synchronize site state for site

You have made a single additive change to the `sites.yaml` file. It is
important to ensure that your branch is otherwise up-to-date with `main`,
as the state you currently have in `sites.yaml` is what will be ensured exists
in the platform.

You may end up undoing changes that other people have done, if you don't have
their changes to `sites.yaml` in your branch.

Prerequisites:

* A Lagoon account on the Lagoon core with your ssh-key associated (created through
  the Lagoon UI, on the Settings page)

From within `dplsh` run the `sites:sync` task to sync the site state in
sites.yaml, creating your new site:

```sh
task site:full-sync
```

Or to sync multiple sites.

```sh
task sites:sync
```

You may be prompted to confirm Terraform plan execution and approve other
critical steps. Read and consider these messages carefully and ensure you are
not needlessly changing other sites.

Be aware that while `site:full-sync` works with a single site in
Lagoon, Terraform always works on all sites, so if you see another
site than the one you're adding in the Terraform plan, abort
immediately.

The synchronization process:

* ensures a Github repo is provisioned for the site
* creates a Lagoon configuration for the site and pushes it to the
  relevant branches in the repo (for example, sites with `plan:
  "webmaster"` also get a `moduletest` branch for testing custom
  Drupal modules)
* ensures a Lagoon project is created for the site
* configures Lagoon to track and deploy all the relevant branches for
  the site as environments

If no other changes have been made to `sites.yaml`, the result is that your new
site is created and deployed to all relevant environments.
