# New environment setup

## Node provisioning
- All nodes should be able to communicate with each other with private ip
- All nodes should have public IP

## K3s cluster setup using Ansible
- Create a host entry in ansible/hosts folder. Example: `ansible/hosts/staging.yaml`
- Create group_vars entry in ansible/group_vars folder. Example: `ansible/group_vars/staging`
- Create Ubuntu user on all hosts
```
ansible-playbook host_ssh_setup.yml -i hosts/staging.yaml --user <hosts-user-name-with-ssh-access>
```
- Run Ansible with environment specific file. Example: `make all <env-name>.yaml`

## K3s setup
- Refer k8s/environment/qa or k8s/environment/sri-lanka-production and create a new folder for new environment

- Replace occurrences `<env-name>` with new environment name in all the files

- Drop datadog folder if monitoring is not required

- Create environment specific values file under `k8s/manifests/*` folders (create new values for new environment)

- Updated the configs and secrets

- Commit and push the changes

- Create DNS entries- Create DNS entries for Argocd and Simple webapp in cloudflare. Use Public IPs of k3s nodes
```
api.<env-name>.simple.org ip
argocd.<env-name>.simple.org ip
metabase.<env-name>.simple.org ip
```

- SSH into one of the master node and cd into `/opt/container-deployment/k8s/environments/<env-name>` and run `git pull`

- To check the status of k3s cluster run `kubectl get nodes` command and all the nodes should be in ready state

- Install sealed secret app. `kubectl apply -f root-app.yaml -n argocd`

- [Follow secrets management to encrypt secrets](./SecretManagement.md)

- Fetch Argocd admin user secrets
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
- Login to the https://argocd.<env-name>.simple.org Argocd app and validate the deployed applications

## Rails setup/commands
Follow [runbook](RUNBOOK.md) for running Rails/DB specific commands

## Simple server CD integration
- Create [Semaphoreci secrets](https://simple.semaphoreci.com/secrets) for Argocd credentials
```
<env-name>_ARGOCD_ENDPOINT
<env-name>_ARGOCD_PASSWORD
```

- Create configuration for CD.
Sample QA configuration
```
  - name: Deploy to QA
    task:
      secrets:
        - name: argocd
      jobs:
        - name: Deploy to QA
          commands:
            - checkout
            - script/argocd_deployment.sh $QA_ARGOCD_ENDPOINT $ARGOCD_USERNAME $QA_ARGOCD_PASSWORD $SEMAPHORE_GIT_SHA
    dependencies: []
```
