# Runbook

## How to open Rails application console?

- Step1: SSH into k8s node
```
ssh ubuntu@159.89.174.186
```

- Step2: Identify Rails container and copy any one container name with prefix `simple-server-`
```
kubectl get pods -n simple-v1
```

- Step3: Login to container
```
kubectl exec -it simple-server-55d6746976-gpqrh /bin/bash -n simple-v1
```

- Step4: Run Rails console command
```
bundle exec rails c
```

## How to open DB console?

- Step1: SSH into k8s node. Select one node ip from hosts [file](ansible/hosts/bd_k3s_demo)
```
ssh ubuntu@159.89.174.186
```

- Step2: Identify Rails container and copy any one container name with prefix `simple-server-`
```
kubectl get pods -n simple-v1
```

- Step3: Login to container
```
kubectl exec -it simple-server-55d6746976-gpqrh /bin/bash -n simple-v1
```

- Step4: Run psql comand
```
psql -U postgres -h postgres-postgresql-ha-pgpool
```

## Decrypt k8s secrets
- Step1: Get k8s cluster node ip. Select one node ip from hosts [file](ansible/hosts/bd_k3s_demo)
```
# Example: 64.227.176.191
```

- Step2: Run the decrypt automation script
```
../scripts/secret-decrypt.py <secret file path> <ip> <ssh user name>
# Example: ../scripts/secret-decrypt.py argocd-apps/bd-k3s-demo/secrets/basicauth.sealedsecret.yaml 64.227.176.191 ubuntu
```
