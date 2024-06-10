# Monitoring

## Add monitoring to a new enviroment
### Update secrets
See [Secret Management](./SecretManagement.md) for more details on using sealed secrets to manage secrets
#### Monitoring Basic Auth
- This secret is used to set the basic auth username and password for prometheus and alertmanager in respective envs
- Generate base64 encoded credentials. Note: Remeber to add these credentials to 1password
```
htpasswd -nb <username> <password> | base64
```
- Create a new decrypted secrets files
```
touch k8s/environments/<env>/secrets/monitoring-basic-auth.sealedsecret.yaml.decrypted
```
- The contents of the file should match the template
```
apiVersion: v1
data:
  auth: <base64-encoded-creds>

kind: Secret
metadata:
  name: monitoring-basic-auth
  namespace: monitoring
type: Opaque
```
- Encrypt the file as a sealed secret
```
cd k8s/environments
./encrypt ~/path/to/vault_password <env>/secrets/monitoring-basic-auth.sealedsecret.yaml.decrypted
./kubeseal_encrypt ~/path/to/env/sealedcerts/pemfile <env>/secrets/monitoring-basic-auth.sealedsecret.yaml.decrypted
```
#### Alertmanager Config
- This secret is used to configure alertmanager
- The process of creating the secret is the same as that for monitoring basic auth.
- Create a new decrypted secrets files
```
touch k8s/environments/<env>/secrets/alertmanager-main.sealedsecret.yaml.decrypted
```
- The contents of the file should match this [template](../k8s/manifests/kube-prometheus/alertmanager-config.yaml.template)
- Encrypt the file as a sealed secret
```
cd k8s/environments
./encrypt ~/path/to/vault_password <env>/secrets/alertmanager-main.sealedsecret.yaml.decrypted
./kubeseal_encrypt ~/path/to/env/sealedcerts/pemfile <env>/secrets/alertmanager-main.sealedsecret.yaml.decrypted
```
#### Grafana Config
- This secret is used to configure grafana
- The process of creating the secret is the same as that for monitoring basic auth.
- Note: Not all environments will require a grafana instance.
- Create a new decrypted secrets files
```
touch k8s/environments/<env>/secrets/grafana-config.sealedsecret.yaml.decrypted
```
- The contents of the file should match this [template](../k8s/manifests/kube-prometheus/grafana.ini.template)
- Encrypt the file as a sealed secret
```
cd k8s/environments
./encrypt ~/path/to/vault_password <env>/secrets/grafana-config.sealedsecret.yaml.decrypted
./kubeseal_encrypt ~/path/to/env/sealedcerts/pemfile <env>/secrets/grafana-config.sealedsecret.yaml.decrypted
```

### Configure App
#### Argocd App
- Add the kube-promethus app to argocd apps
- Update k8s/environments/<env>/argocd-apps/apps.yaml
- Add the following yaml block at the bottom the the the file
```
---

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kube-prometheus
spec:
  destination:
    namespace: monitoring
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    directory:
      jsonnet:
        extVars:
        - name: ENVIRONMENT
          value: <env>
        libs:
          - k8s/manifests/kube-prometheus/vendor
      exclude: '*.json'
    path: k8s/manifests/kube-prometheus
    repoURL: 'https://github.com/simpledotorg/container-deployment.git'
    targetRevision: master
  syncPolicy:
    automated: {}

---
```
#### Jsonnet config
- All non-secret config is present in `k8s/manifests/kube-prometheus/config/`
- Add a config file for the new environment
- Update the configs map in `k8s/manifests/kube-prometheus/monitoring.jsonnet`

### Update systems production datasources
- The new prometheus instance needs to be added as a datasource in the systems production env
- Decrypt the grafana-datasources sealed secret for systems-production
```
./decrypt ~/path/to/vault_password systems-production/secrets/grafana-datasources.sealedsecret.yaml.decrypted.vault
```
- This will (re)generate `systems-production/secrets/grafana-datasources.sealedsecret.yaml.decrypted`
- Decode the base64 string to copy that to a temporary file
- Update the decoded config to add a new datasource
```
- access: proxy
    editable: false
    name: <env-name>
    orgId: 1
    type: prometheus
    url: <promethueus-url>
    basicAuth: true
    basicAuthUser: <promethues-username>
    secureJsonData:
      basicAuthPassword: <promethues-password>
    version: 1
```

### Enable exporters
While most exporters are enabled by default in their manifests, two exporters need to be enabled per environment.
#### Postgres
- Update file `k8s/environments/<env>/op-postgres/simple-server.yaml`
- Add prometheus.io/app key to the instance labels
```
spec:
  instances:
    metadata:
      labels:
        prometheus.io/app: 'postgres'
```
#### Simple
- Update file `k8s/environments/<env>/values/simple.yaml`
- Enable metrics
```
metrics:
  enabled: true
```

### Add CNAME records
- Finally we need to add urls for prometheus, grafana, and alertmanager to the DNS records
- From the cloudflare DNS console, add a new CNAME record for each new url
- The target of the CNAME can be retrived from other records in the same env. 

### Deploy
- Commit the changes and create a pull request
- Once merged, resync the root app from argocd dashboard
