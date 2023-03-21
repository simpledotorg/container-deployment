# Secret Management

Both Ansible Vault and Kubeseal is used to manage secrets.
Ansible Vault: Encrypts raw decrypted secrets for Kubeseal.
Kubeseal: Encrypts and decrypts secrets at k8s level. Kubeseal does not allow local decryption hence Ansible vault is used.

## Prerequisite
* Ansible `brew install ansible`
* Kubeseal `brew install kubeseal`

## Update/edit a secret key
* Step1: Decrypt Vault secrets
* Step2: Edit the secret key
* Step3: Encrypt Vault secrets
* Step4: Encrypt Kubeseal secrets
* Step5: Commit changes

Example: Updated the secret in qa/secrets/simple-server.sealedsecret.yaml
```bash
cd k8s/environments

./decrypt ~/.vault_password_k8s qa/secrets/simple-server.sealedsecret.yaml.decrypted.vault

# Edit the secret key in the file
# Base64 encode secret value
./encrypt ~/.vault_password_k8s qa/secrets/simple-server.sealedsecret.yaml

./kubeseal_encrypt ~/.qa-sealedsecret.pem qa/secrets/simple-server.sealedsecret.yaml.decrypted

# Commit the changes
```

`decrypt` , `encrypt` and `kubeseal_encrypt` supports multiple options to decrypt/encrypt secrets in a all the environments or a specific environment or a specific file. Please refer the usage section for more details.
