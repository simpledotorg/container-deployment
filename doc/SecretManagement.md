# Secret Management

Both Ansible Vault and Kubeseal is used to manage secrets.
Ansible Vault: Encrypts raw decrypted secrets for Kubeseal.
Kubeseal: Encrypts and decrypts secrets at k8s level. Kubeseal does not allow local decryption hence Ansible vault is used.

## Prerequisite
* Ansible `brew install ansible`
* Kubeseal `brew install kubeseal`
* Fetch and save the latest Kubeseal pem file from a K8s node (Note: The pem key is rotated frequently, so be sure to always fetch the latest):
  * [SSH into your environment-specific node](./RUNBOOK.md#ssh)
  * Run the following command to get the Kubeseal certificate:
    ```bash
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubeseal --fetch-cert --controller-namespace sealed-secrets --controller-name=sealed-secrets
    ```
  * Save this to your local machine with a .pem extension (saved as `qa-sealedsecret.pem` in the below example)
* Save the Vault password for k8s from the Simple password manager to your local machine (saved as `~/.vault_password_k8s` in the example below). This will be used to encrypt and decrypt secrets on your local machine.

## Update/edit a secret key
* Step1: Decrypt Vault secrets
* Step2: Edit the secret key
* Step3: Encrypt secrets with Vault
* Step4: Encrypt secrets with Kubeseal
* Step5: Commit changes

**Example**: Update secrets in qa/secrets/simple-server.sealedsecret.yaml
```bash
cd k8s/environments

# This decrypts secrets with Ansible Vault and your Vault password
./decrypt ~/.vault_password_k8s qa/secrets/simple-server.sealedsecret.yaml.decrypted.vault

# Edit secrets in the decrypted file `simple-server.sealedsecret.yaml.decrypted`.

# Secrets in this file are base64-encoded because Kubeseal requires this.
# Ensure your new secrets are encoded appropriately as well before adding to the file.
# You can use the base64 utility on macos to do this.

# This encrypts the updated secrets with Ansible Vault.
./encrypt ~/.vault_password_k8s qa/secrets/simple-server.sealedsecret.yaml.decrypted

# Encrypts updated secrets with Kubeseal
# Here, the Kubeseal certificate is copied over from the qa jumpbox and saved locally as `qa-sealedsecret.pem`
./kubeseal_encrypt ~/.qa-sealedsecret.pem qa/secrets/simple-server.sealedsecret.yaml.decrypted

# Commit the changes
```

`decrypt` , `encrypt` and `kubeseal_encrypt` supports multiple options to decrypt/encrypt secrets in all environments or a specific environment or a specific file. Please refer to the usage section for more details.

## Secrets deployment

The secrets file is auto-synced on [ArgoCD](https://argocd-qa.simple.org/applications/argocd/secrets?view=tree&resource=&node=bitnami.com%2FSealedSecret%2Fsimple-v1%2Fsimple-server%2F0) (find the login credentials on the Simple password manager). To deploy manually, directly update the secrets (don't forget to base64 encode them!) in the simple-server live manifest on ArgoCD and hit `sync`.
