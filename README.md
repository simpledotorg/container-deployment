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
- [Deploy branch for testing k8s manifest changes](./doc/DeployBranch.md)
- [Infra Requirement for the simple web application](./doc/InfraRequirement.md)
- [Manual Changes](./doc/Manual_Changes.md)
- [Create New DHIS2 Instance](./doc/CreateNewDHIS2Instance.md)

## High-Level Architecture

### Components

- **[Kubernetes](https://kubernetes.io/)**: Acts as the container orchestration platform, deploying all application components as containers within a Kubernetes cluster. This setup enables high availability, effective scaling, and seamless management of containerized applications.

- **[ArgoCD](https://argoproj.github.io/cd/)**: Facilitates Continuous Delivery (CD) by automating the deployment and synchronization of Kubernetes configurations. Supports various templating engines like Helm, Kustomize, and Jsonnet, making the management of complex deployments straightforward.

- **[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)**: Used for the secure handling of secrets within the Kubernetes environment. Sealed Secrets are encrypted and safely stored in the repository, to be decrypted in the cluster as required, enhancing the security of sensitive information.

- **[Terraform](https://www.terraform.io/)**: Utilizes Infrastructure as Code (IaC) principles to provision and manage AWS Elastic Kubernetes Service (EKS) clusters. This allows for cloud infrastructure to be defined in code, making it easily reproducible and scalable.

- **[Ansible](https://www.ansible.com/)**: Works alongside Terraform to provision Kubernetes clusters on Virtual Machines (VMs). It automates the setup of VMs and the Kubernetes cluster installation, providing flexibility for deployments across different environments.

- **[Nginx Ingress](https://github.com/kubernetes/ingress-nginx)**: Utilized to route external traffic to the Kubernetes cluster, Nginx Ingress serves as a robust, flexible, and efficient HTTP and reverse proxy server, simplifying the exposure of services to the internet.

- **[Cert-Manager](https://github.com/cert-manager/cert-manager)**: Automates the management of SSL/TLS certificates, including their creation, renewal, and deployment within the Kubernetes environment. This ensures secure communication and the trusted delivery of content.

- **[PostgreSQL Cluster Management](https://github.com/CrunchyData/postgres-operator)**: Managed by the Crunchy Data Kubernetes Operator, which simplifies the deployment and management of PostgreSQL clusters within Kubernetes. This approach leverages Kubernetes' native capabilities to ensure high availability, performance, and scalability of PostgreSQL databases.

- **[Reloader](https://github.com/stakater/Reloader)**: Automatically updates pods in response to config or secret changes. This ensures that applications are always running with the most current configurations and secrets, improving the dynamism and security of deployments.

- **[Datadog Operator](https://docs.datadoghq.com/containers/datadog_operator/)**: Responsible for the collection of logs, metrics, and APM data. By deploying the Datadog Operator within the Kubernetes environment, monitoring and observability are seamlessly integrated, providing comprehensive insights into application performance and system health.

- **Other Components**: In addition to the core components, various other essential services and tools are installed and managed. Please find all the relevant manifests in the `k8s/manifests` directory of this repository

## Folder structure
```
├── ansible # Ansible automation for k3s cluster, firewall, ssh, etc
├── terraform # Cloud infrastructure provisioning
├── k8s # All k8s related resources manifests
│   ├── environments # Base folder for all environments
│   │   └── <environment-name> # Folder for environment specific manifests and configs
│   |     ├── argocd-apps # Argocd application manifests
|   |     ├── configmaps # Configmaps
|   |     ├── secrets # Sealed secrets files
|   |     ├── op-datadog # Datadog operator manifests
|   |     ├── op-postgres # Postgres operator manifests
|   |     ├── values # Environment specific values files for individual components
|   |     ├── ...
│   │       
│   └── manifests # K8s yaml, helm manifests and wrappers for individual components
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
│       |    │   └── ...
│       |    ├── values.bd-k3s-demo.yaml # Override default with demo environment specific values
│       |    ├── values.staging.yaml # Override default with staging environment specific values
│       |    └── values.yaml # Default values
│       |    └── ...
│       ├── argocd # Helm chart for Argocd
│       ├── ingress # Helm chart for Ingress
│       ├── sealed-secrets # Helm chart for Bitnami sealed secrets
│       ├── ...
```
