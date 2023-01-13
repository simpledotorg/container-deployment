# Runbook

## SSH
- List of host for each environment can be found [here](../ansible/hosts/)
- Ansible host file is configured with privates IPs. Use Jump host mentioned in the environment specific [group_vars](../ansible/group_vars/) (variable name: `ansible_ssh_common_args: ... ubuntu@jump-host-ip`)
- SSH into k8s node
```
ssh -A -J ubuntu@jump-host-ip  ubuntu@host-private-ip
```

## How to open Rails application console?

- Step1: [SSH into k8s node](#ssh)

- Step2: Login to container
```
kubectl exec -it simple-server-0 /bin/bash -n simple-v1
```

- Step3: Run Rails console command
```
bundle exec rails c
```

## How to open DB console?

- Step1: [SSH into k8s node](#ssh)

- Step2: Login to container
```
kubectl exec -it simple-server-0 /bin/bash -n simple-v1
```

- Step3: Run psql comand
```
psql -U postgres -h postgres-postgresql-ha-pgpool
```

## [Decrypt/Encrypt k8s secrets](./SecretManagement.md)
