# Infra Requirement for the simple web application

## VM k8s Deployment

### VM Spec
Database VMs (Primary and Secondary) - 2
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 1TB
vCPU: 8
Memory: 32GB
```

Application VMs (Server, Worker, Metabase and other components) - 3
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 8
Memory: 16GB
```

Cache VMs - 1 (Redis)
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 2
Memory: 16GB
```
