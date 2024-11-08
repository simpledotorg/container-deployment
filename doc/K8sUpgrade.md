# Kubernetes Upgrade Notes

## Upgrading K3S Cluster

To upgrade a K3S cluster, start by selecting a target version after testing it locally using Minikube or Kind. Once the target version is decided, identify any intermediary upgrades required to reach that version. For example, if you're on version `v1.28.5+k3s1`, you should first upgrade to the latest patch version in the same major series, in this case, `v1.28.15+k3s1` (as of Nov 8, 2024). Then, proceed to the latest patch of the next major version, such as `v1.29.10+k3s1`, and continue similarly.

All version information can be found on the K3S GitHub release tags [page](https://github.com/k3s-io/k3s/tags).

Here’s the complete version progression for upgrading from `v1.28.5+k3s1` to `v1.31.2+k3s1` (as of Nov 8, 2024):

```
v1.28.5+k3s1 (current version)
    |
v1.28.15+k3s1
    |
v1.29.10+k3s1
    |
v1.30.6+k3s1
    |
v1.31.2+k3s1 (target)
```

**Note:** Please refer to the K3S documentation for any additional steps required when upgrading to a new major version.

### Upgrade Process

The K3S cluster is managed using Ansible. To upgrade, modify the K3S version in the `ansible/group_vars/<environment>/vars.yml` file and then run the `k3s_install.yml` playbook:

```bash
ansible-playbook k3s_install.yml -i hosts/<environment>.yaml
```

## Upgrading AWS EKS Cluster

To upgrade an EKS cluster, follow the AWS Console instructions to complete the upgrade process. Once done, commit the final version back to the Terraform code.
