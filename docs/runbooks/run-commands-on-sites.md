# Run commands on sites

## When to use

When the same command, typically drush, must run on many sites, for example
to change config on every moduletest environment before a change reaches
production.

## Prerequisites

- A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name. It needs a dplsh release that includes GNU Parallel; if
  `parallel` is not found, update with `../tools/dplsh/dplsh.sh --update`.
- A [connected Lagoon CLI](connecting-the-lagoon-cli.md).

## Procedure

1. Choose the sites. `task sites:list` lists every site in `sites.yaml`, and
   `--plan` limits it to the sites on one plan:

   - `webmaster`: the sites that have a moduletest environment.
   - `standard`: every other site, those without `plan` in `sites.yaml`.

   Any other plan is rejected. Put the sites in `SITES`, separated by spaces
   or newlines:

   ```sh
   export SITES="$(task sites:list -- --plan webmaster)"
   ```

   Or name them by hand: `export SITES="aarhus odense"`.

2. Run the command after `--`. It runs with `lagoon ssh` on the `main`
   environment unless `ENVIRONMENT` says otherwise:

   ```sh
   ENVIRONMENT=moduletest task sites:run -- drush cr
   ```

   Three sites run at a time (set `JOBS` to change it). Each site gets one
   attempt; set `TRIES` to allow more, but only for commands that are safe to
   run twice. Each output line is prefixed with its site.

   If any site failed, the task lists those sites at the end and fails. Run
   it as `task -x sites:run …` to get the number of failed sites as the exit
   code, up to 101.

Each argument reaches the site as one word, so shell syntax such as `&&` or
`|` is not interpreted. To use it, wrap the command in `sh -c`:

```sh
task sites:run -- sh -c 'drush updb -y && drush cr'
```

Task reads `{{` in the arguments as a template, so a command containing it,
such as a Twig string, cannot be passed this way.

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
