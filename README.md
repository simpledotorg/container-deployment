# Container deployment
Automation and manifests for container deployment

## Index
- [Secret Management](./doc/SecretManagement.md)
- [Local setup using Minikube](./doc/LocalSetup.md)
- [Runbook](./doc/RUNBOOK.md)
- [Recommended VM requirements](./doc/recommended_vm_requirements.md)
- [New environment creation](./doc/NewEnvironmentSetup.md)
- [Reference docs](./doc/REFERENCES.md)
- [LVM volume setup](./doc/LVMVolumeSetup.md)
- [Basic VM Validations](./doc/VMValidations.md)
- [Datadog Monitoring](./doc/DatadogMonitoring.md)

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
