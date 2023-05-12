# EKS

## Known issues
- [Error deleting security group: DependencyViolation](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2048)
  - Fix: Delete the network interface related to the security group manually
