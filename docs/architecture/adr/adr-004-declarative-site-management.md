# ADR 004: Declarative Site management

## Context

Lagoon requires a site to be deployed from at Git repository containing a
[.lagoon.yml and docker-compose.yml](https://docs.lagoon.sh/lagoon/using-lagoon-the-basics/lagoon-yml)
A potential logical consequence of this is that we require a Git repository pr
site we want to deploy, and that we require that repository to maintain those
two files.

Administering the creation and maintenance of 100+ Git repositories can not be
done manually with risk of inconsistency and errors. The industry best practice
for administering large-scale infrastructure is to follow a declarative
[Infrastructure As Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)(IoC)
pattern. By keeping the approach declarative it is much easier for automation
to reason about the intended state of the system.

Further more, in a standard Lagoon setup, Lagoon is connected to the "live"
application repository that contains the source-code you wish to deploy. In this
approach Lagoon will just deploy whatever the HEAD of a given branch points. In
our case, we perform the build of a sites source release separate from deploying
which means the sites repository needs to be updated with a release-version
whenever we wish it to be updated. This is not a problem for a small number of
sites - you can just update the repository directly - but for a large set of
sites that you may wish to administer in bulk - keeping track of which version
is used where becomes a challenge. This is yet another good case for declarative
configuration: Instead of modifying individual repositories by hand to deploy,
we would much rather just declare that a set of sites should be on a specific
release and then let automation take over.

While there are no authoritative discussion of imperative vs declarative IoC,
the following quote from an [OVH Tech Blog](https://tech.ovoenergy.com/imperative-vs-declarative/)
summarizes the current consensus in the industry pretty well:

> In summary declarative infrastructure tools like Terraform and CloudFormation
> offer a much lower overhead to create powerful infrastructure definitions that
> can grow to a massive scale with minimal overheads. The complexities of hierarchy,
> timing, and resource updates are handled by the underlying implementation so
> you can focus on defining what you want rather than how to do it.
>
> The additional power and control offered by imperative style languages can be
> a big draw but they also move a lot of the responsibility and effort onto the
> developer, be careful when choosing to take this approach.

## Decision

We administer the deployment to and the Lagoon configuration of a library site
in a repository pr. library. The repositories are provisioned via Terraform that
reads in a central `sites.yaml` file. The same file is used as input for the
automated deployment process which renderers the various files contained in the
repository including a reference to which release of DPL-CMS Lagoon should use.

It is still possible to create and maintain sites on Lagoon independent of this
approach. We can for instance create a separate project for the [dpl-cms](https://github.com/danskernesdigitalebibliotek/dpl-cms)
repository to support core development.

## Status

Accepted

## Alternatives considered

We could have run each site as a branch of off a single large repository.
This was rejected as a possibility as it would have made the administration of
access to a given libraries deployed revision hard to control. By using individual
repositories we have the option of grating an outside developer access to a
full repository without affecting any other.
