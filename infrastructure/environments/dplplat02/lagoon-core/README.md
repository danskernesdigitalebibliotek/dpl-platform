# Updating Lagoon Core using SOPS encrypted values file

## Information about the SOPS encrypted file

The lagoon-core.values.sops.yaml file is a SOPS encrypted values file
containing our configuration of Lagoon Core. This file contains all credentials
for all of the Lagoon Core dependant services.
Having all the credentials available makes the upgrade process more trustworthy
and reliable as only the changes the updates to the chart brings are shown when
running `helm diff upgrade`.
OBS: The lagoon-core-baas-repo-pw secret will show a
diff as well, but this is expected as Amazee hasn't enabled setting that secret
via the values file. According to the code, the secret should not be replaced
upon updating the chart, but the `helm diff` command doesn't know that. Here's
a link to that [secret](https://github.com/uselagoon/lagoon-charts/blob/main/charts/lagoon-core/templates/k8up.secret.yaml)

## How to update Lagoon Core

Ensure you have logged into the `az cli`. If you need to login run `az login`.
Lagoon Core is updated by first updating the upgrade-lagoon-core.sh script with
the appropriate version and then running ./upgrade-lagoon-core.sh in your
terminal. This instruction assumes that due dilligence has been done in
updating the lagoon-core.values.sops.yaml file according to instructions from
the Lagoon documentation. Please leave in the `diff` and `--dry-run` when
commiting to git - this makes the script more fat-finger-proof.

## How to make changes to the encrypted lagoon-core.values.sops.yaml file

To make changes to the SOPS encrypted lagoon-core.values.sops.yaml file requires
having the sops cli tool installed. Installation instructions can be found
[here](https://getsops.io/docs/#download)

With SOPS installed you can now run `sops edit lagoon-core.values.sops.yaml` and
make the changes needed.

Alternatively, a decrypted file can be output by running `sops -d lagoon-core.
values.sops.yaml > lagoon-core.values.dec.yaml`
