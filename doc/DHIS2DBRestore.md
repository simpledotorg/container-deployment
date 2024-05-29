# Restore DHIS2 database from a backup file on Kubernetes instance

## Steps

1. Copy backup file to the Kubernetes db container.

```
kubectl cp <backup-file> <name-space>/<postgres-pod-name>:/pgdata/
```

2. Restore the database from the backup file.

```
kubectl exec -it <pod-name> bash -n <name-space>

# Connect to the postgres database
psql

# Kill the existing connections
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'dhis'
  AND pid <> pg_backend_pid();

# Drop the existing database. Please take a backup before dropping the database if needed.
DROP DATABASE dhis;

# Exit from psql

# Restore the database from the backup file
gunzip -c dhis.gz | psql dhis

# Restart the tomcat server pod
kubectl delete pod <name-space>/<tomcat-pod-name>
```
