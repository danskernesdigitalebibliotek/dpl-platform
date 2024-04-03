# ADR 005: Declarative Site management (2)

## Context

We have previously established ([in ADR 004](adr-004-declarative-site-management.md))
that we want to take a declarative approach to site management. The previous
ADR focuses on using a single declarative file, `sites.yaml`, for driving
Github repositories that can be used by Lagoon to run sites.

The considerations from that ADR apply equally here. We have identified more
opportunities to use a declarative approach, which will simultaneously
significantly simplify the work required for platform maintainers when managing
sites.

Specifically, runbooks with several steps to effectuate a new deployment are a
likely source of errors. The same can be said of having to manually run
commands to make changes in the platform.

Every time we run a command that is not documented in the source code in the
platform `main` branch, it becomes less clear what the state of the platform is.

Conversely, every time a change is made in the `main` branch that has not yet
been execute, it becomes less clear what the state of the platform is.

## Decision

We continuously strive towards making the `main` branch in the dpl-platform repo
the single source of truth for what the state of the platform should be. The
repository becomes the declaration of the entire state.

This leads to at least two concrete steps:

- We will automate synchronizing state in the platform-repo with the actual
  platform state. This means using `sites.yaml` to declare the expected state
  in Lagoon (e.g. which projects and environments are created), not just the
  Github repos. This leaves the deployment process less error prone.

- We will automate running the synchronization step every time code is checked
  into the `main` branch. This means state divergence between the platform repo
  declaration and reality is minimized.

It will *still* be possible for `dpl-cms` to maintain its own area of state
in the platform, but anything declared in `dpl-platform` will be much more
likely to be the actual state in the platform.

## Status

Proposed
