# ADR 006: In-cluster Database

## Context

We have had too much downtime due to the Azure MariaDB Database, which is
managed by Azure. Azure is barring us access to the database server logs due
to their disproportionate pricing of server logs. This results in an inability
to investigate database slowness as well as what lead to a database crash.
Instead we've had to wait for Azure support to allocate time and resources
towards advising/assisting us.

We have also experienced the Azure support taking unsanctioned action on the
database, resulting in downtime for all sites, on serveral occasions.

The sum of all this is an erroded trust in Azure ability to cater adequately
to our needs.

By moving the database into the cluster, we gain access to the database server
logs, access to the server itself and a guarantee that no one but the platform
team takes actions and thus.
We have the experience running databases in cluster, and having the power and
agency to do the things we know need doing, should result in less down time for
the sites as well as the ability to bring the sites backup faster.

### Pros & Cons

#### Azure Managed DB

##### Cons

- Experienced to be poorly managed
- Server logs is disproportionately priced = too expensive for this project
- We don't have access to the server
- The wait time for support can be long and very bothersome as well as
incorrect.
- Server might be (was in our case) misconfigured
- Will require a migration to a potentially as bad service

##### Pros

- One-click setup
- Minimal configuration needed from us
- Azure support
- Azure can be blamed for downtime, they are directly or indirectly responsible
for.
- MySql, which is not set to be sunsettet, might have a noticably better service
as that is their chosen flavor to keep offering.

#### In-Cluster DB

##### Cons

- We have no one but ourselves to blame if something goes awry
- Logging and Monitoring has to be set up manually
- All configuration has to be done ourselves
- Not possible to do PITR recovery at the moment.

##### Pros

- Ability to investigate logs
- Logging and monitoring can be set up to alert us to noteworthy changes
- A little cheaper on the face of it
- Ability to split out databases such that one database having issues doesn't
cause all sites to crash.
- Possible to run in a HA setup if we should decide to do so.
- Performance can be optimized and finetuned to our usecase
- Databases will be located closer, logically as well as physically, to
workloads relying on them = faster response time, which should be noticable for
end-users.
- We can right-size the databae, thereby getting the maximum performance for the
buck.

## Decision

We have made the decision to implement the In-cluster database due the
afforemention pros and cons lists.
We are tired of having a poorly managed database, with bad support.
Additionally both, we and the DDF, as well as the libraries themselves are
tired of having preventable downtime.
This way we take our agency back and ensure that we will not have an incoming
task of migrating the database later in the year, when Azure End-Of-Lifes
Managed MariaDB's.

We will start by implementing a PoC, where we can test for a good setup of the in-cluster
database before migrating all the databases to use the in-cluster databases.
The PoC will also be used for testing mgiration against.

Every step taken towards moving into in-cluster database shall done
transparantly.

The In-cluster database must:
- have ressource monitoring setup
- be able to have backups taken
- Be able to be restored
- Have log monitoring setup

## Status

Approved
