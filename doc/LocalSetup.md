# New local environment setup using Minikube

## Prerequisite
- Install docker `brew install docker` or [follow docker installation guide](https://docs.docker.com/desktop/install/mac-install/)
- Install minikube `brew install minikube`
- Start minikube `minikube start --kubernetes-version=v1.24.7 --memory 6144 --cpus 4`
- Install helm `brew install helm`
- Install kubeseal `brew install kubeseal`
- Install ngrok `brew install ngrok`

## Install Argocd
- Add hem repo `helm repo add argo https://argoproj.github.io/argo-helm`
- Install `helm install argocd argo/argo-cd --create-namespace -n argocd --set notifications.secret.create=false --version 5.14.1`

## Create manifests
- Create a new branch for local setup `git checkout -b local-<your-name>`. Replace `<your-name>`, ex: `local-john`
- Replace the `targetRevision: local` to `targetRevision: local-<your-name>` in `k8s/environments/local/argocd-apps` and ` k8s/environments/local/root-app.yaml`
- Git push branch `git push origin local-<your-name>`

## Create root Argocd app
- `kubectl create -f  k8s/environments/local/root-app.yaml -n argocd`

## View Argocd UI
- Fetch `admin` user passworld `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- Expose UI on local host 8080 port `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Open UI in browser https://localhost:8080/

## Encrypt secrets
- Create a decrypted secret file (dummy base64 encoded values)
```
cat <<EOF > k8s/environments/local/secrets/simple-server.sealedsecret.yaml.decrypted
apiVersion: v1
data:
  APPOINTMENT_NOTIFICATION_ORG_IDS: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  DHIS2_PASSWORD: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  DHIS2_URL: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  DHIS2_USERNAME: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  DHIS2_VERSION: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  EXOTEL_SID: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  EXOTEL_TOKEN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  EXOTEL_VIRTUAL_NUMBER: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  GOOGLE_ANALYTICS_ID: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  PURGE_URL_ACCESS_TOKEN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  RAILS_CACHE_REDIS_PASSWORD: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SECRET_KEY_BASE: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SENDGRID_PASSWORD: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SENDGRID_USERNAME: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SENTRY_CURRENT_ENV: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SENTRY_DSN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SENTRY_SECURITY_HEADER_ENDPOINT: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  SIMPLE_APP_SIGNATURE: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_ACCOUNT_SID: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_AUTH_TOKEN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_PHONE_NUMBER: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_REMINDERS_ACCOUNT_AUTH_TOKEN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_REMINDERS_ACCOUNT_PHONE_NUMBER: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_REMINDERS_ACCOUNT_SID: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_TEST_ACCOUNT_SID: YmFzZTY0LWVuY29kZWQtdmFsdWU=
  TWILIO_TEST_AUTH_TOKEN: YmFzZTY0LWVuY29kZWQtdmFsdWU=
kind: Secret
metadata:
  name: simple-server
  namespace: simple-v1
type: Opaque
EOF
```
- Encrypt the secrets using Kubeseal
```
kubeseal <k8s/environments/local/secrets/simple-server.sealedsecret.yaml.decrypted >k8s/environments/local/secrets/simple-server.sealedsecret.yaml -o yaml --controller-namespace sealed-secrets --controller-name=sealed-secrets
```
- Commit and push the encrypted secrets to git
- Wait for Argocd sync to complete

## Login to simple server pod setup db
- Login `kubectl exec -it simple-server-0 bash -n simple-v1`
- Run db schema load `bundle exec rake db:schema:load`
- Run db migrate `bundle exec rake db:migrate`
- Run db seed `bundle exec rake db:seed`

## Access simple app UI
- `kubectl port-forward svc/simple-server -n simple-v1 8081:80`
- `ngrok http 8081`
