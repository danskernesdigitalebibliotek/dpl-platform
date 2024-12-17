# Lagoon projects

The Lagoon instance at `dplplat01.dpl.reload.dk` contains a range of
sites of a slightly different nature.

## Development sites

Development sites set up [directly in
Lagoon](./runbooks/add-generic-site-to-platform/). These usually
automatically build select branches and pull requests and are
primarily for testing in development.

Currently this includes `dpl-cms` project (main development) and the
`dpl-bnf` project ("Bibliotekernes Nationale Formidling" content
sharing system).

## Production/staging sites

Sites managed by
+[`sites.yml`](./runbooks/add-library-site-to-platform/). This process
creates a GIT repository in the
[`danishpubliclibraries`](https://github.com/danishpubliclibraries/)
GitHub organization. These repositories is then updated when running
the `task sites:sync`, which causes Lagoon to deploy the new version.
