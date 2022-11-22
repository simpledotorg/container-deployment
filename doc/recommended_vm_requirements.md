# Recommended VM requirements

While Simple can be deployed onto almost any configuration of VMs, we recommend
the following VM configuration for an optimal deployment. This configuration allows
each of Simple's components (eg. database, web servers, background job servers) to
run on a dedicated VM.

Database VMs - 2
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
Data storage disk: 1TB
vCPU: 8
Memory: 16GB
PublicIP: Required
```

Application VMs - 11
```
OS: Ubuntu 22.04 LTS
Default disk: 100GB
vCPU: 4
Memory: 8GB
PublicIP: Required
```

Total VM count: 13
