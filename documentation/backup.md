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
for more general information.

Refer to any [runbooks](runbooks) relevant to backups for operational instructions
on eg. retrieving a backup.
