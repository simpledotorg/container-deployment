# Create New DHIS2 Sandbox/Dev/Demo Instance

As we use k8s for deploying DHIS2, for creating a new instane we just have to create few configurations and checking to git

## Steps

1. Create a nodepool for this instance by adding a cofiguration in `terraform/sandbox/main.tf`. Please refer to the existing nodepool configurations for reference. Replace the configurations as needed. Apply the terraform configuration to create the nodepool.
2. Add DHIS2 and Postgres Argocd apps in `k8s/environments/sandbox/argocd-apps/apps.yaml`. Please refer to the existing sandbox apps for reference in the same file. Replace the name, namespace and other configurations as needed.
3. Crate a values file for the new instance `k8s/environments/sandbox/values` folder. Please refer to the existing values files for reference. Replace the configurations as needed.
4. Create a CNAME DNS for the new instance in Cloudflare. Please refer to the existing CNAMEs for reference and the CNAME values will be same only the DNS name will be different. We are using domain based routing.
5. Create a folder and configuration for postgres under `k8s/environments/sandbox/op-postgres` folder. Please refer to the existing postgres configurations for reference. Replace the configurations as needed.
6. Create secrets for dhis2 and pg. Sample secrets `k8s/environments/sandbox/secrets/dhis2-htn-tracking-pgbackrest.sealedsecret.yaml.decrypted.vault`
`k8s/environments/sandbox/secrets/dhis2-htn-tracking.sealedsecret.yaml.decrypted.vault`. Please refer the secret management [doc](./SecretManagement.md) for more detail.

Sample commits for creating a new instance
- https://github.com/simpledotorg/container-deployment/commit/e5d59d256388e300d807f4292d6e013969b5f3a0
- https://github.com/simpledotorg/container-deployment/commit/da4bc0bee8c660b655d5e335030eea0af9be6197
