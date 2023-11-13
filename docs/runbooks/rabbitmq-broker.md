# RabbitMQ broker force start

## When to use

When the PR environments are no longer being created, and the
`lagoon-core-broker-<n>` pods are missing or not running, and the container logs
contain errors like `Error while waiting for Mnesia tables:
{timeout_waiting_for_tables`.

This situation is caused by the RabbitMQ broker not starting correctly.

## Prerequisites

* A [dplsh session](using-dplsh.md) with DPLPLAT_ENV exported .

## Procedure

You are going to exec into the pod and stop the RabbitMQ application, and then
start it with [the `force_boot`
feature](https://www.rabbitmq.com/rabbitmqctl.8.html#force_boot), so that it can
perform its Mnesia sync correctly.

Exec into the pod:

```shell
dplsh:~/host_mount$ kubectl -n lagoon-core exec -ti pod/lagoon-core-broker-0 -- sh
```

Stop RabbitMQ:

```shell
/ $ rabbitmqctl stop_app
Stopping rabbit application on node rabbit@lagoon-core-broker-0.lagoon-
core-broker-headless.lagoon-core.svc.cluster.local ...
```

Start it immediately after using the `force_boot` flag:

```shell
/ $ rabbitmqctl force_boot
```

Then exit the shell and check the container logs for one of the broker pods. It
should start without errors.
