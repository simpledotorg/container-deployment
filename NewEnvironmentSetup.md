# New environment setup

## Node provisioning
- All nodes should be able to communicate with each other with private ip
- All nodes should have public IP
- All nodes should have Ubuntu user and ssh access

## K3s cluster setup using Ansible
- Create a host entry in ansible/hosts folder. Example: `ansible/hosts/staging.yaml`
- Create group_vars entry in ansible/group_vars folder. Example: `ansible/group_vars/staging`
- Run Ansible with environment specific file. Example: `make all <env-name>.yaml`

## K3s setup
- Copy k8s/environment/example folder to a new environment specific folder `cp k8s/environment/example k8s/environment/<env-name>`
Example: k8s/environment/staging
- Replace occurrences `<env-name>` with new environment name in all the files
- Drop datadog folder if monitoring is not required
- Create environment specific values file under `k8s/manifests/argocd`, `k8s/manifests/simple/redis` and `k8s/manifests/simple/server` and tweak configurations accordingly
- Commit and push the changes
- SSH into one of the master node and cd into `/opt/container-deployment/k8s/environments/<env-name>/argocd-apps` and run `git pull`
- To check the status of k3s cluster run `kubectl get nodes` command and all the nodes should be in ready state
- Install sealed secret app. `kubectl apply -f sealed-secrets.yaml -n argocd`
- Run below command to fetch the secrete encryption key. Change `<env-name>-sealedsecret.pem` in the command with new environment name
```
KUBECONFIG=/etc/rancher/k3s/k3s.yaml ./kubeseal --fetch-cert > <env-name>-sealedsecret.pem --controller-namespace sealed-secrets --controller-name=sealed-secrets
```
- Save the key under `/scripts/<env-name>-sealedsecret.pem` in your local machine and commit the change
- Install kubeseal on local machine. `brew install kubeseal`
- Update the secrets under `k8s/environment/<env-name>/secrets` with valid base64 encoded keys
- Encrypt the secret using kubeseal. Replace `<env-name>` in the command with new environment name and commit the secrets to git

```
# Simple server secrets
kubeseal <k8s/environments/<env-name>/secrets/simple-server.sealedsecret.yaml.decrypted >k8s/environments/<env-name>/secrets/simple-server.sealedsecret.yaml --cert scripts/<env-name>-sealedsecret.pem -o yam

# Datadog secrets
kubeseal <k8s/environments/<env-name>/secrets/datadog.sealedsecret.yaml.decrypted >k8s/environments/<env-name>/secrets/datadog.sealedsecret.yaml --cert scripts/<env-name>-sealedsecret.pem -o yam
```
- Create DNS entries for Argocd and Simple webapp in cloudflare. Use Public IPs of k3s nodes
```
api.<env-name>.simple.org ip
argocd.<env-name>.simple.org ip
```
- SSH into one of the master node and cd into `/opt/container-deployment/k8s/environments/<env-name>/argocd-apps` and run `git pull`
- Install all the components required. `kubectl apply -f ./ -n argocd`
- Fetch Argocd admin user secrets
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
- Login to the https://argocd.<env-name>.simple.org Argocd app and validate the deployed applications

## Rails setup/commands
Follow [runbook](RUNBOOK.md) for running Rails/DB specific commands

## Simple server CD integration
- Create [Github action secrets](https://github.com/simpledotorg/simple-server/settings/secrets/actions) for Argocd credentials in simple-server repo
```
<env-name>_ARGOCD_ENDPOINT
<env-name>_ARGOCD_PASSWORD
```

- Create configuration for CD. Add a section for new environment in `.github/workflows/container.yml` in simple-server repo and commit/push the changes
```
  deploy_simple_server_<env-name>:
    needs: docker_build_push
    runs-on: ubuntu-latest
    container:
      image: argoproj/argocd:v2.4.11
    steps:
      - name: Argocd login
        run: argocd login ${{ secrets.<env-name>_ARGOCD_ENDPOINT }} --username ${{ secrets.ARGOCD_USERNAME }} --password ${{ secrets.<env-name>_ARGOCD_PASSWORD }} --insecure --config /home/argocd/.config/argocd/config
      - name: Argocd set simple server image
        run: argocd app set simple-server --helm-set image=simpledotorg/server:$GITHUB_SHA --config /home/argocd/.config/argocd/config
      - name: Argocd wait for sync
        run: argocd app wait simple-server --config /home/argocd/.config/argocd/config
```
