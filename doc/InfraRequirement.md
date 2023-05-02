# Infra Requirement for the simple web application

## VM Deployment

### VM Spec
Database VMs (Primary and Secondary) - 2
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 1TB
vCPU: 16
Memory: 64GB
```

Database VMs (DB Backup) - 1
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 2TB
vCPU: 4
Memory: 8GB
```

Application VMs (Server and Worker) - 7
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

Cache VMs - 2 (Reids)
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 4
Memory: 16GB
```


Load balancer(Nginx ingress) - 2
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 2TB
vCPU: 4
Memory: 8GB
```

Metabase VMs (Server and Worker) - 1
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

K3s master servers - 3
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 2TB
vCPU: 4
Memory: 8GB
```

Total VM count: 18

### VM Network
- SSH access to all VMs
- VMs should be able to communicate with each other
- VMs should be able to communicate with the internet
- Outbound HTTP/HTTPS, SMTP, DNS and NTP traffic should be allowed

### WAF
- WAF should be terminate ssl and forward traffic to the load balancer port 80
- WAF should be able to communicate with the load balancer
- WAF should forward X-Forwarded-For, X-Forwarded-Proto, X-Forwarded-Host, X-Forwarded-Port, X-Forwarded-Server, X-Real-IP headers to the load balancer
- WAF should redirect HTTP traffic to HTTPS

## K8s Deployment

### K8s Cluster Spec
- Cluster with public endpoint
- Version: v1.24
- Enable CSI for storage
- Enable VPC CNI for networking
- Enable CoreDNS for DNS
- Enable ssh access to the cluster nodes

### K8s Node pools
Node pool: Database (Primary and Secondary) - 2
```
Labels: role-db: true
Default disk: 100GB
Data storage disk: 1TB (CSI volume)
vCPU: 16
Memory: 64GB
```

Node pool: Application (Server) - 5
```
Labels: role-server: true
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

Node pool: Application (Worker) - 2
```
Labels: role-worker: true
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

Node pool: Cache1 - 1 (Reids)
```
Labels: role-cache-redis: true
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

Node pool: Cache2 - 1 (Reids)
```
Labels: role-worker-redis: true
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

Node pool: Load balancer(Nginx ingress) - 2
```
Labels: role-ingress: true
Default disk: 100GB
Data storage disk: 2TB
vCPU: 4
Memory: 8GB
```

Node pool: Metabase VMs (Server and Worker) - 1
```
Labels: role-metabase: true
Default disk: 100GB
vCPU: 4
Memory: 16GB
```

### Application load balancer
- Load balancer should be able to communicate with ingress node pool VMs (target group with node pool auto scaling)
- Terminates SSL and forward traffic to the ingress node pool
- Redirect HTTP traffic to HTTPS

### S3 buckets
- Bucket for storing database backups
- Bucket for storing application logs
