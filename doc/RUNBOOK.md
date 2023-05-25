# Runbook

## Connecting to k8s cluster
We have two type of k8s clusters. One is VM based cluster using k3s and the other is EKS cluster. Connecting to these two clusters are different.
EKS uses IAM roles to authenticate and VM based cluster uses kubeconfig file on the VM to authenticate.
Why we have two different clusters? Because we have two different environments. One is in AWS/Could and the other is data center.

### EKS cluster
- Get access to respective AWS account

- Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

- Configure aws cli with your credentials
```
# Example for bangladesh staging cluster
# Create a profile in the ~/.aws/credentials file
...
[bangladesh]
aws_access_key_id = <access-key>
aws_secret_access_key = <secret-key>
...
```

- Create a profile for assume role
  - Get `role_arn` from `terraform output` variable `eks_assume_role_arn` or from AWS console IAM role page (search for `eks-system-admin`)
```
# Example for bangladesh staging cluster
# Create another profile in the ~/.aws/credentials file
...
[bangladesh-staging-k8s]
role_arn = arn:aws:iam::<account-id>:role/eks-system-admin-<cluster-name>
source_profile = bangladesh
...
```

- Get the kubeconfig file from AWS
  - Get eks cluster name from `terraform output` variable `eks_cluster_name` or from AWS console EKS cluster page
```
# Example for bangladesh staging cluster
aws eks --region ap-south-1 update-kubeconfig --name staging-simple-k8s-01 --profile bangladesh-staging-k8s
```

- Check if you can connect to the cluster
```
kubectl get nodes
```

### VM based cluster
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

- Step1: [SSH into k8s node](#connect-to-k8s-cluster)

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

Note: For `QA` and `Test` environments Semaphore CI/CD will `automatically` update the SSH keys.

For other environments, you need to manually update the SSH keys.
Run the following command.

```bash
make update-ssh-keys hosts=<your_deployment_name.yaml>
```

Note: Run this command from jump box in Sri Lanka DC, [steps](#sri-lanka-dc-ssh)

## DB backup and restore

Reference docs: [DB backup](https://access.crunchydata.com/documentation/postgres-operator/5.2.0/tutorial/backup-management/) | [DB restore](https://access.crunchydata.com/documentation/postgres-operator/5.2.0/tutorial/disaster-recovery/)

### One-Off Backup
- Add the following to k8s/environments/<env>/op-postgres/simple-server.yaml file
```yaml
spec:
  backups:
    pgbackrest:
      manual:
        repoName: repo1
        options:
         - --type=full
```

- Add following annotations
```bash
kubectl annotate -n simple-v1 postgrescluster simple postgres-operator.crunchydata.com/pgbackrest-backup="$(date)"
```
Wait for the backup cron job to complete. You can check the status in Argocd UI

### Perform an In-Place Point-in-time-Recovery
- Add the following to k8s/environments/<env>/op-postgres/simple-server.yaml file
```yaml
spec:
  backups:
    pgbackrest:
      restore:
        enabled: true
        repoName: repo1
        options:
        - --type=time
        - --target="2021-06-09 14:15:11-04"
```
Note: Replace the target time with the time you want to restore to

- Add following annotations
```bash
kubectl annotate -n simple-v1 postgrescluster simple --overwrite \
  postgres-operator.crunchydata.com/pgbackrest-restore=id1
```
Wait for the restore cron job to complete. You can check the status in Argocd UI

- And once the restore is complete, in-place restores can be disabled:
```yaml
spec:
  backups:
    pgbackrest:
      restore:
        enabled: false
```

## Enable aws eks gp2 volume expansion
Note: Required for increasing the size of the database volumes
```
kubectl patch sc gp2 -p '{"allowVolumeExpansion": true}'
```
