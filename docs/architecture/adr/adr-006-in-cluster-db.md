# ADR 006: In-cluster Database

## Context

Microsoft has decided to sunset Azure Database for MariaDB summer 2025.
They recommend moving to their Azure Database for MySql instead.

The project has experienced project wide down time due to database crashes on
multiple occasions:

- 17.01.2025: Database went down due to a restart initiated by the Azure Product
Group team taking unsanctioned action
- 15.01.2025: Database went down due to a restart initiated by the Azure Product
Group team taking unsanctioned action
- 9.01.2025: Database went down as a result of to many login requests
- 28.11.2024: Database went down due to too many active connection attempts
- 7.11.2024: Database went down due to too many connections
- Summer 2024: Database was restarted by Azure for unscheduled and unnotified
maintenance

Microsofts datbase server logs are prohibitively expensive.
Microsoft misconfigured the database provision-time.
Microsofts support is tiered and direct access to technical staff is prevented
by Azure support policy.
Microsofts support has made unsanctioned changes on the databse
It is not possible to access the database server.

Installing a MariaDB Sql operator in the cluster provides the following
benefits:

- access to the database server logs
- access to the server itself
- a guarantee that no one but the platform team can take action on the server
- ability to right-size the database
- Running clusters of databases
- Database recovery
- The ability to start recovering from a crash immediately

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
