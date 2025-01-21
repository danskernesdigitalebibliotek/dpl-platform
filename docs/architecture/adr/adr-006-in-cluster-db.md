# ADR 006: In-cluster Database

## Context

We have known, since summer 2024, that Microsoft had decided to sunset Azure
database for MariaDB. Their recommendation has been to migrate to their Flexible
MySql database which they have provided pretty well documented. Back then we had
already experienced database downtime, which prompted us to start a discussion
about wether to move the databse to Azure Flexible MySql server or to an
in-cluster database. This conversation has been running for the better part of
6-8 months.

The main points we kept debating was:

- Can we operate an in-cluster database on par or better than Azure?
- Are we able to deal with problems that might arise on the databases with out
Azures Technical Support?
- If we self host the databse, are we then able to optimize the performance?
- Can we guarantee a better or on par uptime to Azure's managed database if we
selfhost the database?
- Would we get better support if we moved to the suggested managed database?
- Would the performance be better on the database suggested by Azure?
- Would downtime be minimized if we moved to the sugggested manged database?

We have continually, and to a worsening degree, seen even more downtime since
summer. We have been cut-off from having insight into the logs of the database
due to an extremely steep price on server logs, which we tried enabling during
the summer. This resulted in a more than doubled operations cost, which the
operations budget in now way can bear.
We have on serveral occasions found the database to have been misconfigured, to
such a degree that it has caused unreasonable downtime.

The expertise and technical support of Azure has been a factor in favor of
migrating to Azure manged MySql database. As mentioned before we have already
seen Azure neglience to setup database configured to correctly to the specs
readily available from MariaDB's documentation on operating a database.
We have on multiple occasions experienced that the database has crashed due to
e.g. too many connection, too many slow queries, which should be the exact thing
the database should have been configured to handle in a reasonable way.
The reasonable behaviour in the afforementioned cases would have been, "too
many connections" and "Ressource busy", which should have resulted in end-user
experiences such as 500 errors and not project/nation wide downtime.

Conversations with the Azure Technical Support is seeped in effective solution
conversations. This is due to:

- Language barriers as the Azure support is handled by people whos English
proficiency is wildly varying.
- The tiered support which bars us from talking to the actual technical staff.
This results in a knowledge relay bottleneck, often resulting in
lost-in-translation situations.
- Tranparency issues stemming from somewhere inside of the technical support,
where information is withheld in such a way that it builds mistrust to Azure.

Lastly we have experienced Azure Technical Support taking unsanctioned actions
on the database, resulting in project wide downtime on serveral occasions. The
first time we exprienced this was summer 2024, where they restarted the databse
while doing some configuration. That last time was january 2025, where they
restarted the database multiple times trying to fix a bad database recovery.

Deranged has dealt with managed databases in the past, and has never experienced
a level of service as bad as this.

Deranged has been managing databases in-cluster for the last 7 years. During
this time, Deranged has managed the following database types:

- Postgress
- MongoDB
- MariaDB/MySql
- ElasticSearch
- Redis
- InfluxDB

By moving the database into the cluster, we gain:

- access to the database server logs
- access to the server itself
- a guarantee that no one but the platform team takes actions on the server
- access to the server logs and thus insight into how to tweak the databaes to
perform better


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
- The wait time for support can be long and incorrect.
- Server might be (was in our case) misconfigured
- Will require a migration to a potentially as bad service

##### Pros

- One-click setup
- Minimal configuration needed from us
- Azure support
- Azure can be blamed for downtime, they are directly or indirectly responsible
for.
- MySql, which is not set to be sunset, might have a noticably better service
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
