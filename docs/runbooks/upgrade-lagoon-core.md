# Upgrade Lagoon Core

This runbook describes how to safely upgrade Lagoon Core.

## Prerequisites

- Access to out kubernetes cluster
- [Meld](https://meldmerge.org/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Sops](https://getsops.io/docs/)
- [AZ CLI](https://learn.microsoft.com/da-dk/cli/azure/install-azure-cli?view=azure-cli-latest)

## Backup databases

First take a backup of the API DB and the Keycloak DB and export it to a local
machine. This will be needed if a roll-back is needed. This is due to various
migrations Amazee runs in these databases during an upgrade.
Run the backup and dump with `task lagoon:backup:core-and-keycloak` which will
export the dumps to `/infrastructure`.

## pull down the newest version of the values file

Go to `/lagoon-core/`
Run `helm show values lagoon/lagoon-core --version x.y.z > values-x-y-z.yaml`

## Decrypt the lagoon-core.values.sops.yaml file

The file is encrypted because it contains credentials to all of the Lagoon
services. These can't be handled differently at this point in time.
Decrypt the file by running: `sops -d -i lagoon-core.values.sops.yaml`.
This decrypts the file in place.

## Compare the old against the new Values file

Run `meld lagoon-core.values.sops.yaml values-x-y-z.yaml`. This opens new
window in the meld program.
Run throught it and ensure we only accept the changes we actually want.
Remember to pull down the changes to the `lagoon-core.values.sops.yaml` file.

## Encrypt the lagoon-core.values.sops.yaml file again

Run  `sops -e -i lagoon-core.values.sops.yaml`. This encrypts the file in-place.

## Helm diff the updated values file

Open the `upgrade-lagoon-core.sh` script and ensure it runs with `diff`.
Then run the script and go over the changes. The checksum for all resources will
have changed and there is nothing we can do about it.

## Run the upgrade

Remove the `diff` command from the upgrade script and run the script again.
It will now uprade Lagoon Core.
