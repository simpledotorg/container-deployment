# Runbook

## Connecting to a K8s cluster
We have two type of K8s clusters. One is VM based cluster using k3s and the other is EKS cluster. Connecting to these two clusters are different.
EKS uses IAM roles to authenticate and VM based cluster uses kubeconfig file on the VM to authenticate.
Why we have two different clusters? Because we have two different environments. One is in AWS/Could and the other is data center.

### Prerequisite

- Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

### Connecting to AWS EKS cluster

- Get access to the respective AWS account

- Configure aws cli with your credentials by creating a source profile in the `~/.aws/credentials` file
  ```
  # Example for bangladesh staging cluster

  ...
  [bangladesh]
  aws_access_key_id = <access-key>
  aws_secret_access_key = <secret-key>
  ...
  ```

- Create a profile for the assumed role
  - Get the role arn using the below options
    - Option 1: Using aws cli
      ```
      aws iam list-roles --profile <profile-name> | grep eks-system-admin`
      ```
    - Option 2: Using aws console. Search for `eks-system-admin` role in the IAM role page.
    - Option 3: From `terraform output` variable `eks_system_admin_role_arn`
  - Add the arn under a new role profile in `~/.aws/credentials` file
    ```
    # Example for bangladesh staging cluster

    ...
    [bangladesh-staging-k8s]
    role_arn = arn:aws:iam::<account-id>:role/eks-system-admin-<cluster-name>
    source_profile = bangladesh
    ...
    ```

- Get the kubeconfig file from AWS
  - Get the cluster name using the below options
    - Option 1: Using aws cli
      ```
      aws eks list-clusters --region ap-south-1 --profile <source-profile-name>
      ```
    - Option 2: Using the AWS console EKS cluster page
    - Option 3: From `terraform output` variable `eks_cluster_name`
  - Add the context to your local kubeconfig
    ```
    aws eks --region ap-south-1 update-kubeconfig --name <cluster-name> --profile <role-profile-name>
    ```

- Check if you can connect to the cluster
  ```
  kubectl get nodes
  ```

### Connecting to VM based cluster
- List of host for each environment can be found [here](../ansible/hosts/)
- Ansible host file is configured with privates IPs. Use Jump host mentioned in the environment specific [group_vars](../ansible/group_vars/) (variable name: `ansible_ssh_common_args: ... ubuntu@jump-host-ip`)
- SSH into K8s node
```
ssh -A -J ubuntu@jump-host-ip  ubuntu@host-private-ip
```

### Sri Lanka DC SSH

To establish an SSH connection to the virtual machines (VMs) located in the Sri Lanka data center, you must utilize a jump host due to the data center's restriction of allowing only a single public IP to initiate connections.

- **Add Your SSH Keys to the Jump Host**: Initially, you need to register your SSH keys with the jump host. You can do this by editing the SSH configuration file located [here](../ansible/group_vars/sri_lanka_production_jumpbox/vars.yml).

- **Register Your SSH Keys with the VMs**: Similarly, to gain access to the VMs, your SSH keys must also be added to the VMs' configuration. This is done by updating another configuration file found [here](../ansible/group_vars/sri_lanka_production/vars.yml).

- **Update SSH Keys on the VMs**: Request an individual who already has access to execute the SSH keys update process. This involves running an Ansible command within a VM to update the keys across the system. Here's the sequence of commands to perform this update:

  ```bash
  ssh -J ubuntu@3.7.92.234 -p 6547 ubuntu@122.255.9.11
  cd ~/simple/container-deployment/ansible
  git pull
  ansible-playbook -i hosts/sri_lanka_production.yaml host_ssh_setup.yml
  ```

After completing the above steps, you will be equipped to connect to the VM using the following SSH command:

```bash
ssh -J ubuntu@3.7.92.234 -p 6547 ubuntu@122.255.9.11
```

## How to open Rails application console?

- Step1: [SSH into K8s node](#connect-to-k8s-cluster)

- Step2: Login to container
```
kubectl exec -it simple-server-0 /bin/bash -n simple-v1
```

- Step3: Run Rails console command
```
bundle exec rails c
```

## How to open DB console?

- Step1: [SSH into K8s node](#ssh)

- Step2: Login to container
```
kubectl exec -it simple-server-0 /bin/bash -n simple-v1
```

- Step3: Run psql comand
```
PGPASSWORD=$SIMPLE_SERVER_DATABASE_PASSWORD psql -h $SIMPLE_SERVER_DATABASE_HOST -U $SIMPLE_SERVER_DATABASE_USERNAME -d $SIMPLE_SERVER_DATABASE_NAME
```

## [Decrypt/Encrypt K8s secrets](./SecretManagement.md)

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

## Argocd user management

### Add new user to Argocd
- Select argocd.yaml file from `k8s/environments/<env>/values/` folder
- Add new user and assign role
```
argo-cd:
  ...
  configs:
    cm:
      ...
      accounts.<user-name>: login
...
    rbac:
      ...
      policy.csv: |
        ...
        g, <user-name>, role:<role-name>
```
- Create a PR and merge to master post review
- ArgoCD will automatically sync the changes
- Existing users can set the password using [below steps](#generateupdate-argocd-user-password)
### Generate/update Argocd user password
Install argocd cli: `brew install argocd`
```
argocd login <endpoint-without-https://-prefix>
argocd account update-password --account <user-name>
```

Use scripts/argocd_password_setup.py for bulk password update
```
cp scripts/argocd_password_setup_credentials.txt.sample scripts/argocd_password_setup_credentials.txt
cp scripts/argocd_password_setup_users.txt.sample scripts/argocd_password_setup_users.txt
# Update the credentials file with argocd credentials
# Update the users file with user names
python scripts/argocd_password_setup.py
```

## Deploy your branch to a K8s cluster

- Create a pull request for your branch
- On SemaphoreCI, navigate to the workflow tab for your pull request. Under `Promotions`, hit `Docker build and push`.
- Once the promotion job finishes, get the image tag SHA from the [container registry](https://hub.docker.com/r/simpledotorg/server/tags)
- Update the image tag on the [respective ArgoCD](https://docs.google.com/spreadsheets/d/1JCfFYetk9Jrtc5iUHp-7Fx5V3QqpuCWojjcEibRJN7I/edit#gid=0): Application (eg: simple-server) > App Details > Parameters > image.tag
- Wait for the application to finish auto-syncing
