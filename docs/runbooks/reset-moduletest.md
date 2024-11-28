# Reset moduletest site

## When to use

When a moduletest site need resetting.

## Prerequisites

* An authenticated `az` cli. The logged in user must have full administrative
  permissions to the platforms azure infrastructure.
* A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.

## Procedure

From within `dplsh` run:

```sh
PROJECT=<site> task sites:webmaster:reset-moduletest
```

Where `<site>` is the site to reset.
