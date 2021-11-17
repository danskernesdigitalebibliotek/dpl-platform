# Backup

## Site backup configuration
We configure all production backups with a backup schedule that ensure that the
site is backed up at least once a day.

Backups executed by the [k8up operator](https://k8up.io/) follows a backup
schedule and then uses [Restic](https://restic.net/) to perform the backup
itself. The backups are stored in a Azure Blob Container, see the [Environment infrastructure](architecture/platform-environment-architecture.md)
for a depiction of its place in the architecture.

The backup schedule and retention is configured via the individual sites
`.lagoon.yml`. The file is re-rendered from a template every time the a site is
deployed. The templates for the different site types can be found as a part
of [dpladm](../infrastructure/dpladm).

Refer to the [lagoon documentation on backups](https://docs.lagoon.sh/lagoon/using-lagoon-advanced/backups)
for more information

## Retrieving backups
Citing the [Lagoon backup documentation](https://docs.lagoon.sh/lagoon/using-lagoon-advanced/backups#retrieving-backups)
> Backups stored in Restic will be tracked within Lagoon, and can be recovered via the "Backup" tab for each environment in the Lagoon UI.

Backups can be downloaded on demand. Restoring a backup onto a running site
is a manual process where an administrator first copies the backup into a
site pod eg. via `kubectl cp` and then copies files into their destination and
imports databasedumps via eg. `drush sqlc`.
