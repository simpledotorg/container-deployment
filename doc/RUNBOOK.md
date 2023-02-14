# Runbook

## SSH
- List of host for each environment can be found [here](../ansible/hosts/)
- Ansible host file is configured with privates IPs. Use Jump host mentioned in the environment specific [group_vars](../ansible/group_vars/) (variable name: `ansible_ssh_common_args: ... ubuntu@jump-host-ip`)
- SSH into k8s node
```
ssh -A -J ubuntu@jump-host-ip  ubuntu@host-private-ip
```

### Sri Lanka DC SSH
- To connect to Sri Lanka VMs using ssh, use SSLVPN web portal (Credentials are in password management tool)
- And connect jump box VM (Credentials are in password management tool)
- Switch to Ubuntu user `sudo su - ubuntu -c zsh`
- CD to container deployment folder `cd /opt/container-deployment`

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
PGPASSWORD=$SIMPLE_SERVER_DATABASE_PASSWORD psql -h $SIMPLE_SERVER_DATABASE_HOST -U $SIMPLE_SERVER_DATABASE_USERNAME -d $SIMPLE_SERVER_DATABASE_NAME
```

## [Decrypt/Encrypt k8s secrets](./SecretManagement.md)

## Update SSH keys

To manage the authorized SSH keys that can access your servers,

First, add or remove the appropriate SSH keys from the `group_vars/<your deployment name>/vars.yml` file

Then, run the following command.

```bash
make update-ssh-keys hosts=<your_deployment_name.yaml>
```

Note: Run this command from jump box in Sri Lanka DC, [steps](#sri-lanka-dc-ssh)
