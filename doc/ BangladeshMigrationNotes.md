# Simple Bangladesh Migration to Data Center (Notes)

Migrating Simple to a data center (DC) in Bangladesh will be challenging due to the nature of the infrastructure provisioned in the DC. An ideal approach is to provision up-to-date Ubuntu-based servers, deploy a K3S cluster, and follow the standardized deployment process used across environments. This is the same method we used for the Sri Lanka DC migration.

## Exposing the Simple Application to the Internet

In some data centers, a WAF (Web Application Firewall) with SSL termination may be provided. If available, this can be used to expose the services to the public internet. If a WAF is not provided, an Ingress can handle this, given a node with a public IP address.

## Capacity Planning

During provisioning, ensure that there is sufficient capacity for future scaling, both in terms of VM resources and disk space for the database.

## Database Backups

Ensure that databases are backed up to a different data center or cloud-based storage for disaster recovery purposes.

## Migration Strategy

Since Simple is an offline-first app, a downtime-based migration approach is viable, ideally scheduled during a weekly off day. Data entry within the application will remain unaffected during the migration.

## References

Please refer to the Sri Lanka migration [document](https://docs.google.com/document/d/18vMGSFfMwz4FGI3Bcg65rTeOeeYyn0M-GYaFVsWUS1M) and [epic](https://app.shortcut.com/simpledotorg/epic/9477) for more detailed steps.
