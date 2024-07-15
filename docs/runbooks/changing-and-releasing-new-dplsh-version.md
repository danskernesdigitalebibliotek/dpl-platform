# Make changes to DPLSH

## When to use

When for example the `kubectl` or other dependencies needs updating

## Make the change

1. Go to the DPLSH directory and make the necessary changes on a new branch
2. Build DPLSH locally by running `IMAGE_URL=dplsh IMAGE_TAG=someTagName task build`
3. Test that it works by running `DPLSH_IMAGE=dplsh:local ./dplsh` and running what ever commands need to be run to test that the change has the desired effect
4. Check what version DPLSH is at here: https://github.com/danskernesdigitalebibliotek/dpl-platform/releases
5. Push the branch, have it review and merge it into `main`
6. Push a new tag to `main`. The tag should look like this: `dplsh-x.x.x`. (If in doubt about what version to bump to; read this: https://semver.org/)
7. Wait for main to automically build and release the new version
8. Go to your main branch, enter the `/infrastructure` directory and run `../tools/dplsh/dplsh.sh --update`.

You are done and have the newest version of DPLSH on your machine.
