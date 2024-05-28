# Create New DHIS2 Sandbox/Dev/Demo Instance

As we use k8s for deploying DHIS2, for creating a new instane we just have to create few configurations and checking to git

## Steps

1. Create a new branch branch
2. Create a nodepool for this instance by adding a cofiguration in `terraform/sandbox/main.tf`. Please refer to the existing nodepool configurations for reference. Replace the configurations as needed. Apply the terraform configuration to create the nodepool.
3. Add DHIS2 and Postgres Argocd apps in `k8s/environments/sandbox/argocd-apps/apps.yaml`. Please refer to the existing sandbox apps for reference in the same file. Replace the name, namespace and other configurations as needed.
4. Crate a values file for the new instance `k8s/environments/sandbox/values` folder. Please refer to the existing values files for reference. Replace the configurations as needed.
5. Create a CNAME DNS for the new instance in Cloudflare. Please refer to the existing CNAMEs for reference and the CNAME values will be same only the DNS name will be different. We are using domain based routing.
6. Create a folder and configuration for postgres under `k8s/environments/sandbox/op-postgres` folder. Please refer to the existing postgres configurations for reference. Replace the configurations as needed.
