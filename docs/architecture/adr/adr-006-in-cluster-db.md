# ADR 006: In-cluster Database

## Context

Microsoft is [sunsetting Azure Database for MariaDB by September 2025](https://azure.microsoft.com/en-us/updates?id=azure-database-for-mariadb-will-be-retired-on-19-september-2025-migrate-to-azure-database-for-mysql-flexible-server).
They recommend moving to Azure Database for MySql instead.

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

Microsoft's database server logs are prohibitively expensive.
Microsoft misconfigured the database provision-time.
The current Microsoft support tier is useless and useful support is
prohibitively expensive.
Microsoft support has made unsanctioned changes on the databse, such as
maintenance work during business hours and restarts in attempts to fix support
tickets.

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

#### Azure Database for MySQL

##### Cons

- Negative experiences from management of Azure Database for MariaDB
  - The project has experienced project wide down time due to database crashes on
multiple occasions:
- Server logs are disproportionately priced. They are too expensive for this project. This prevents us from debugging many problems ourselves.
- The wait time for support can be long and incorrect.
- Server might be (was in our case) misconfigured

##### Pros

- One-click setup
- Minimal configuration needed from us
- Azure support
- Azure can be blamed for downtime, they are directly or indirectly responsible
for.
- MySql, which is not set to be sunset, might have a noticably better service
as that is their chosen flavor to keep offering.
- Support for hight-availability with automatic failover to a replica

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
- Support for [high-availability](https://mariadb.com/docs/server/architecture/use-cases/high-availability/) if we decide to implement this.
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
