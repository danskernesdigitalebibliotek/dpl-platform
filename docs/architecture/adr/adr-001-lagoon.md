# Architecture Decision Record: Lagoon

## Context

The Danish Libraries needed a platform for hosting a large number of Drupal
installations. As it was unclear exactly how to build such a platform and how
best to fulfill a number of requirements, a Proof Of Concept project was
initiated to determine whether to use an existing solution or build a platform
from scratch.

After an evaluation, [Lagoon](https://docs.lagoon.sh/lagoon/) was chosen.

## Decision

The main factors behind the decision to use Lagoon where:

* Much lower cost of maintenance than a self-built platform.
* The platform is continually updated, and the updates are available for free.
* A well-established platform with a lot of proven functionality right out of
  the box.
* The option of professional support by [Amazee](https://amazee.io)

When using and integrating with Lagoon we should strive to

* Make as little modifications to Lagoon as possible
* Whenever possible, use the defaults, recommendations and best practices
  documented on eg. [docs.lagoon.sh](https://docs.lagoon.sh/lagoon/)

We do this to keep true to the initial thought behind choosing Lagoon as a
platform that gives us a lot of functionality for a (comparatively) small
investment.

## Alternatives considered

The main alternative that was evaluated was to build a platform from scratch.
While this may have lead to a more customized solution that more closely matched
any requirements the libraries may have, it also required a very large
investment would require a large ongoing investment to keep the platform
maintained and updated.

We could also choose to fork Lagoon, and start making heavy modifications to the
platform to end up with a solution customized for our needs. The downsides of
this approach has already been outlined.
