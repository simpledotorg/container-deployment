# Container deployment
Automation and manifests for container deployment

## Index
- [Runbook](./doc/RUNBOOK.md)
- [Recommended VM requirements](./doc/recommended_vm_requirements.md)
- [New environment creation](./doc/NewEnvironmentSetup.md)
- [Reference docs](./doc/REFERENCES.md)

## Folder structure
```
├── ansible # Host level Ansible automation for firewall, ssh, etc
├── k8s # All k8s related resources manifests
│   ├── environments # Base folder for all environments
│   │   └── <environment-name> # Folder for environment specific manifests
│   |     ├── argocd-apps # Argocd application manifests
|   |     ├── configmaps # Configmaps
|   |     ├── secrets # Sealed secrets files
|   |     ├── op-datadog # Datadog operator manifests
|   |     ├── op-postgres # Postgres operator manifests
│   │       
│   └── manifests # K8s yaml, helm manifests for individual components
│       └── simple-server # Helm chart for simple server
│       |    ├── charts # Packaged dependency
│       |    ├── Chart.yaml # Chart metadata
│       |    ├── templates # Helm template folder
│       |    │   ├── cron.yaml
│       |    │   ├── ingress.yaml
│       |    │   ├── migration-job.yaml
│       |    │   ├── server.yaml
│       |    │   ├── service.yaml
│       |    │   └── worker.yaml
│       |    ├── values.bd-k3s-demo.yaml # Override default with demo environment specific values
│       |    ├── values.staging.yaml # Override default with staging environment specific values
│       |    └── values.yaml # Default values
│       ├── argocd # Helm chart for Argocd
│       ├── ingress # Helm chart for Ingress
│       ├── sealed-secrets # Helm chart for Bitnami sealed secrets
```

## Metrics integration with Datadog
With Datadog pod annotations Datadog k8s operator will automatically collect metrics using [Autodiscovery feature](https://docs.datadoghq.com/containers/kubernetes/integrations/?tab=kubernetesadv2)

### Option 1: Using native Datadog integration
Pros
- No additional cost for native integrations

Cons
- Direct connection to applications is required (Ex: Datadog will connect to Postgres with user to fetch metrics)

[Sample](https://github.com/simpledotorg/container-deployment/blob/master/k8s/manifests/simple/redis/values.yaml#L7-L20) annotation for Redis
```
redis:
  master:
    podAnnotations:
      ad.datadoghq.com/redis.checks: |
        {
          "redisdb": {
            "init_config": {},
            "instances": [
              {
                "host": "%%host%%",
                "port":"6379",
                "password":"%%env_REDIS_PASSWORD%%"
              }
            ]
          }
        }
```

### Option2: Using metrics exporters and collecting the same using datadog custom integration
Pros
- Compatible with most of the monitoring systems (Ex: prometheus)
- Direct connection to application is not required

Cons
- Additional cost for custom metrics in Datadog

[Sample](https://github.com/simpledotorg/container-deployment/blob/master/k8s/manifests/simple/pgo-postgres/postgres.yaml#L40-L4) annotation for Postgres
```
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: simple
spec:
  ...
  instances:
    - name: instance1
      ...
      metadata:
        labels:
          tags.datadoghq.com/service: "postgrescluster-simple"
          tags.datadoghq.com/version: "14"
        annotations:
          ad.datadoghq.com/database.check_names: '["openmetrics"]'
          ad.datadoghq.com/database.init_configs: '[{}]'
          ad.datadoghq.com/database.instances: '[{"prometheus_url":"http://%%host%%:9187/metrics","namespace": "crunchy_data","metrics": ["*"]}]'
```
