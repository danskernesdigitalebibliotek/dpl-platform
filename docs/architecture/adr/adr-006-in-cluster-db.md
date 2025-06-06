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

In light of this, we have to consider options.

## Considered options

- In-cluster MariaDB
- Azure Database for MySql

### Pros & Cons

#### Azure Database for MySQL

##### Cons

- Negative experiences from management of Azure Database for MariaDB
- The project has experienced project wide down time due to database crashes on
multiple occasions:
- Server logs are disproportionately priced. They are too expensive for this
  project. This prevents us from debugging many problems ourselves.
- The wait time for support can be long and incorrect.
- Server might be (was in our case) misconfigured
- Potential data-mismatch, that must be handled migration time

##### Pros

- One-click setup
- Minimal configuration needed from us
- Azure support
- Azure can be blamed for downtime, they are directly or indirectly responsible
for.
- MySql, which is not set to be sunset, might have a noticeably better service
as that is their chosen flavor to keep offering.
- Support for hight-availability with automatic failover to a replica

#### In-Cluster DB

##### Cons

- We have no one but ourselves to blame if something goes awry
- Logging and monitoring has to be set up manually
- [Point-in-time-recovery is not supported at the moment](https://github.com/mariadb-operator/mariadb-operator/issues/507)
- All configurations and updates have to be done by us

##### Pros

- Ability to investigate logs
- Troubleshooting can be done immeadiately
- Logging and monitoring can be set up to alert us to noteworthy changes.
- The server resources are cheaper and will allow us to have more powerful
  databases at a lower cost.
- Ability to split out databases such that one database having issues doesn't
  cause all sites to crash.
- Support for [high-availability](https://mariadb.com/docs/server/architecture/use-cases/high-availability/)
  if we decide to implement this.
- Performance can be optimized and finetuned to our usecase
- Databases will be located closer, logically as well as physically, to
workloads relying on them = faster response time, which should be noticable for
end-users.
- We can right-size the database, thereby getting the maximum performance for the
buck.
- Direct access to the server itself.

## Decision

We have made the decision to implement the In-cluster database due the
aforemention pros and cons lists.
Negative experiences with stability and management for Azure Database for
MariaDB have reduced our trust in continual use of managed databases by Azure.
By moving to an in-cluster database get control over a critical part of our
infrastructure

We will start by implementing a PoC, where we can test for a good setup of the in-cluster
database before migrating all the databases to use the in-cluster databases.
The PoC will also be used for testing migration against.

Every step taken towards moving into in-cluster database shall done
transparantly.

The In-cluster database must:

- Have resource monitoring setup
- Be able to have backups taken
- Be able to be restored
- Have log monitoring setup

## Status

Approved
