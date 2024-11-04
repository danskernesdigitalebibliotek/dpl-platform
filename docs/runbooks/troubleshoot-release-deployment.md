# Troubleshooting

During the deployment process you may encounter problems. This is a list of
known problems and how to address them.

If a problem is not mentioned explicitly it should be raised to team which is
most likely responsible:

* All deployment steps prefixed with *Post-Rollout*: Application developers
* All other errors: Platform administrators

## Platform-related errors

A Lagoon deployment can end up with a *Failed* status. If this is the case then
the following errors may show up in the log output shown for the deployment in
the Lagoon UI.

### TLS handshake timeout

If the log output of a deployment contains the following during various stages
of the deployment then redeploy the environment from the Lagoon UI:

`Unable to connect to the server: net/http: TLS handshake timeout`

This may be caused by a spike in load during deployment.

### Context deadline exceeded

If the log output of a deployment contains the following then redeploy the
environment from the Lagoon UI:

`failed to call webhook: Post "[Ingress url]": context deadline exceeded`

This may be caused by a spike in load during deployment.

### Harbor authentication failed

If log output for the deployment contains the following during the *Image Push
to Registry* stage of the deployment then redeploy the environment from the
Lagoon UI:

`level=fatal msg="copying system image from manifest list: trying to reuse blob
sha256:[SHA] at destination: checking whether a blob sha256:[SHA] exists in
[Harbor url]: authentication required"`

This is caused by [a bug in Harbor](https://github.com/goharbor/harbor/issues/18971).
It should be addressed in a future update of this part of the platform.

### MySQL server has gone away

If log output for the deployment contains the following during the *Post-Rollout
drush deploy* stage of the deployment then redeploy the environment from the
Lagoon UI:

`Drupal\Core\Database\DatabaseExceptionWrapper: SQLSTATE[HY000]: General error:
2006 MySQL server has gone away`

This may be caused by intermittent database problems caused by spike in load
during deployments.

### Service deployment exceeded its progress deadline

If log output for the deployment contains the following during the *Applying
Deployments* stage of the deployment then redeploy the environment from the
Lagoon UI:

```shell
Waiting for deployment "[Service]" rollout to finish: 1 old replicas are pending
termination...
error: deployment "varnish" exceeded its progress deadline`
```

This may be caused by a spike in load during deployment.

### Drush bootstrap failed

If log output for the deployment contains the following during the *Post-Rollout
drush deploy* stage of the deployment then redeploy the environment from the
Lagoon UI:

```shell
The command "/app/vendor/bin/drush updatedb --uri=https://[Domain]" failed.`
Exit Code: 1(General error)
[...]
Bootstrap failed. [...]
```

This may be caused by intermittent database problems caused by spike in load
during deployments.
