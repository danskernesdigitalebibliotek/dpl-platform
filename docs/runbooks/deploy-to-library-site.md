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

