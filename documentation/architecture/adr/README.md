# Architecture Decision Records

We loosely follow the guidelines for ADRs [described by Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

A record should attempt to capture the situation that led to the need for a
discrete choice to be made, and then proceed to describe the core of the
decision, its status and the consequences of the decision.

To summaries a ADR could contain the following sections (quoted from the above
article):

- **Title**: These documents have names that are short noun phrases. For example,
 "ADR 1: Deployment on Ruby on Rails 3.0.10" or "ADR 9: LDAP for Multitenant Integration"

- **Context**: This section describes the forces at play, including technological
  , political, social, and project local. These forces are probably in tension,
  and should be called out as such. The language in this section is value-neutral.
  It is simply describing facts.

- **Decision**: This section describes our response to these forces. It is stated
  in full sentences, with active voice. "We will …"

- **Status**: A decision may be "proposed" if the project stakeholders haven't
  agreed with it yet, or "accepted" once it is agreed. If a later ADR changes
  or reverses a decision, it may be marked as "deprecated" or "superseded" with
  a reference to its replacement.

- **Consequences**: This section describes the resulting context, after applying
 the decision. All consequences should be listed here, not just the "positive"
 ones. A particular decision may have positive, negative, and neutral consequences,
 but all of them affect the team and project in the future.

<!--
Template

# ADR nnn: <name>

## Context

## Decision

## Status

## Alternatives considered

-->
