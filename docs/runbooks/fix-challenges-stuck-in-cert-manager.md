# Fix challenges stuck in Cert-manager

We sometimes experience that Cert-manager either chokes on some certificate/
challenge or backoffs for such a long time that the challenge doesn't get
handled in a timely manner

This is guide on how to fix this.

## When to use:

The development team is usually the first to write that some development
environment they have provisioned, doesn't get a certificate.
It may sometimes come from the libraries or DDF themselves.

## Prerequisites:

You'll need `kubectl` configured to access the cluster. Either use the binary
on your machine or use it from `DPLSH`.

## Procedure:

1. Check how many challenges exists accross namespaces.
2. Check the logs of the leader Cert-manager pod. If it is handling certicates
wait until it is not.
3. Kill the leader pod. It should now start handling the challenges again.

Step 3 might have to be repeated several times until the challenges has all
been handled.

OBS: We have some subdomains that have not been configured by the libraries
themselves yet. Thus we have some 10+ challenges that are always there.
