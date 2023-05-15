output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "assume_role_arn" {
  value = aws_iam_role.eks_system_admin.arn
}
