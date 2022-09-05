# Containerization

## Folder structure
```
├── ansible # Host level Ansible automation for firewall, ssh, etc
├── k8s # All k8s related resources manifests
│   ├── argocd-apps # Argocd application manifests
│   │   └── bd-k3s-demo # Environment specific manifests
│   └── manifests # K8s yaml, helm manifests for individual components
│       ├── argocd
│       ├── grafana
│       ├── ingress
│       ├── sealed-secrets
│       └── simple
```
