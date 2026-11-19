# Run commands on sites

## When to use

When the same commands, typically drush via `lagoon ssh`, must run on many
sites, for example to change config on every moduletest environment before
a change reaches production.

## Prerequisites

- A running [dplsh](using-dplsh.md) with `DPLPLAT_ENV` set to the platform
  environment name.
- A [connected Lagoon CLI](connecting-the-lagoon-cli.md).

## Procedure

1. Write the commands to a file, one per line. `{site}` is replaced with the
   site's key from `sites.yaml`. Blank lines and `#` comments are ignored.

   ```sh
   lagoon ssh -p {site} -e moduletest -C "drush config:set -y my_module.settings my_key value"
   lagoon ssh -p {site} -e moduletest -C "drush cr"
   ```

2. Check which sites and commands it will run:

   ```sh
   task sites:run-commands -- -c commands.txt --plan webmaster --dry-run
   ```

   Leave out `--plan` to target every site. `--plan webmaster` selects the
   sites that have a moduletest environment.

3. Run it without `--dry-run`. Three sites run at a time, and each command
   is retried up to five times. Each site's commands run in order, and a
   site stops at its first failing command. The output of each site goes to
   `run-commands-logs/<timestamp>/<site>.log`.

4. If sites failed, re-run only those:

   ```sh
   task sites:run-commands -- -c commands.txt --sites run-commands-logs/<timestamp>/failed.txt
   ```

Run `task sites:run-commands -- --help` for the remaining options.

### Commands must not prompt

Each command runs with stdin from `/dev/null`, so nothing can answer a
prompt:

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
drush config:set -y --input-format=yaml my_module.settings my_flag false
```
