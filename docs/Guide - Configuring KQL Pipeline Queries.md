# Guide - Configuring KQL Pipeline Queries

Adding a new table to the ADX-to-LogAnalytics-Scanner requires coordination across multiple system components to maintain the end-to-end data flow integrity. This process ensures schema consistency, proper data transformation, and seamless i



The recommended method for adding KQL queries for scraping incoming ADX data is by adding queries to the YAML `queries.yaml` file.  This allows for proper CI/CD management of the Function App under expected Enterprise Governance conditions.

<img title="" src="./img/Queries-YAML.jpg" alt="" width="679" data-align="center">

## YAML Queries Structure

| YAML Element            | Description                                                                                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Root <br/>(i.e. Syslog) | This is the destination table name for Log Analytics.  Multiple queries may be nested under this table type.                                            |
| name                    | A non-functional name for the query                                                                                                                     |
| description             | A non-functional descriptionfor the query                                                                                                               |
| query                   | The query that will filter and forward events to Sentinel.  Note that the query will automatically be injected with Time filtering between invocations. |

## Log Analytics Query Pack Structure

Optionally, queries may be sourced from a Log Analytics Query Pack where the destination table name matches a label for a query.

I've come to the conclusion that this approach is problematic for an Enterprise environment.  Change should really be managed through code and preserved with DevSecOps processes.  The Log Analytics Query Pack doesn't have a user friendly interface either.

The integration code for using a Log Analytics Query Pack remains in this example application to demonstrate the flexibility of Function Apps rather than a preferred method of query management.
