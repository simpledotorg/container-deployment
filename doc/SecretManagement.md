# Secret Management

Both Ansible Vault and Kubeseal is used to manage secrets.
Ansible Vault: Encrypts raw decrypted secrets for Kubeseal.
Kubeseal: Encrypts and decrypts secrets at k8s level. Kubeseal does not allow local decryption hence Ansible vault is used.

## Update/edit a secret key
* `cd k8s/environments`
* ` ./decrypt /path/to/vault/password/file`
* Update the relevant secret files. Example: `sri-lanka-production/secrets/simple-server.sealedsecret.yaml.decrypted`
* `./encrypt /path/to/vault/password/file`
* Fetch and save the latest Kubeseal pem file form K8s master node using `KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubeseal --fetch-cert --controller-namespace sealed-secrets --controller-name=sealed-secrets`. Note: PEM key is rotated every month, hence always fetch latest PEM key
* `./kubeseal_encrypt environment/folder /path/to/kubeseal/pemfile/file`. Example: `./kubeseal_encrypt qa ../../scripts/qa-sealedsecret.pem`
* Commit changes to git
