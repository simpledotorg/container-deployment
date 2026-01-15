# EKS

## Known issues
- [Error deleting security group: DependencyViolation](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2048)
  - Fix: Delete the network interface related to the security group manually
- [Error: The configmap "aws-auth" does not exist](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009)
  - Fix: Uncomment #token... line in eks.tf file under provider "kubernetes" and comment the exec section. And undo the change after the cluster is created.
- [EC2 instance Names are blank](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2032)
