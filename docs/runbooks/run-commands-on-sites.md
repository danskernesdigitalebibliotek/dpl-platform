# Run commands on sites

## When to use

When the same command, typically drush, must run on many sites, for example
to change config on every moduletest environment before a change reaches
production.

## Prerequisites

- A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
- A [connected Lagoon CLI](connecting-the-lagoon-cli.md).

## Procedure

1. Choose the sites. `task sites:list` lists every site in `sites.yaml`, and
   `task sites:list -- --plan webmaster` lists the sites that have a
   moduletest environment. Put the sites in `SITES`, separated by spaces or
   newlines:

   ```sh
   export SITES="$(task sites:list -- --plan webmaster)"
   ```

   Or name them by hand: `export SITES="aarhus odense"`.

2. Run the command after `--`. It runs with `lagoon ssh` on the `main`
   environment unless `ENVIRONMENT` says otherwise:

   ```sh
   ENVIRONMENT=moduletest task sites:run -- drush cr
   ```

   Three sites run at a time (set `JOBS` to change it), and a failing command
   is retried up to five times. Each output line is prefixed with its site.
   The task exits with the number of sites that still failed.

Each argument reaches the site as one word, so shell syntax such as `&&` or
`|` is not interpreted. To run several commands, run the task once for each.

### Commands must not prompt

Nothing can answer a prompt:

- drush takes the prompt's default answer without asking. Pass `-y` so the
  result does not depend on that default.
- When `sshkey:` is set in `~/.lagoon.yml`, `lagoon ssh` skips the ssh-agent
  and reads the key file itself, so a passphrase-protected key prompts and
  fails with `inappropriate ioctl for device`. Set `sshkey: ""` and load the
  key with `ssh-add` before running.

To set a boolean config value, add `--input-format=yaml`. Without it drush
passes the value as a string, and a boolean in config schema casts `"false"`
to `true`:

```sh
task sites:run -- drush config:set -y --input-format=yaml my_module.settings my_flag false
```
