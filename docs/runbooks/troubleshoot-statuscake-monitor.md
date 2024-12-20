# Troubleshoot StatusCake alert

## When to use

When [StatusCake](https://www.statuscake.com/) raises an alert about a library
site being down.

## Prerequisites

- Access to the used StatusCake account
- Access to [Grafana](../platform-environments.md)
- Access to [Lagoon UI](../platform-environments.md)

## Procedure

1. Determine whether the site is accessible by accessing the `/health` endpoint
   for the site
2. Note the response
3. Log into [StatusCake](https://www.statuscake.com/)
4. Locate the uptime test for the library site in question
5. Find the downtime root cause for alert based on the time the alert.
6. Click *Extra details*
7. Note the error
8. Log into Grafana
9. Click *Explore*
10. Add a label filter with the label *namespace* and value being the name of
    the site being down.
11. Add a label filter with the label *app* and value *php*
12. Set the time range to include the start of the alert
13. Note any errors

## Known problems

These are a list of known problems and how to address them.

### DNS lookup errors

#### Observations

- StatusCake reports *Request timeout* and `EAI_AGAIN` additional data.

#### Action

You can ignore this error. StatusCake is experiencing DNS lookup issues. These
are outside the scope of the platform.

### Corrupt Drupal cache

#### Observations

- `/health` reports HTTP status code 500
- Grafana logs contain PHP exceptions

#### Action

1. Log into Lagoon UI
2. Locate the project in question
3. Locate the environment in question
4. Locate *Tasks*
5. Run the task *Clear Drupal caches* for the environment in question
6. Wait for the task to finish
7. Verify that `/health` reports HTTP status code 200

### Database connection errors

#### Observations

- `/health` reports HTTP status code 500
- Grafana logs contain `PDOException: SQLSTATE[HY000]`

#### Actions

Do nothing. This is likely caused by a restart of the underlying database.
Experience shows that it takes about 20 minutes for the restart to complete.

Note that such errors will affect all sites running on the platform and will
result in multiple alerts being raised.
