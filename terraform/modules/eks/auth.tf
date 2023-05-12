data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "eks_system_admin" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [data.aws_caller_identity.current.account_id]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "eks_system_admin" {
  assume_role_policy = data.aws_iam_policy_document.eks_system_admin.json
  name               = "eks-system-admin-${module.eks.cluster_name}"
}

data "aws_iam_policy_document" "eks_console_access" {
  statement {
    actions   = ["eks:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "eks_console_access" {
  name   = "EKSConsoleAccess-${module.eks.cluster_name}"
  policy = data.aws_iam_policy_document.eks_console_access.json
}

resource "aws_iam_role_policy_attachment" "developer_eks_console_access" {
  role       = aws_iam_role.eks_system_admin.name
  policy_arn = aws_iam_policy.eks_console_access.arn
}

data "aws_iam_policy_document" "eks_cluster_role_assumer" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = [aws_iam_role.eks_system_admin.arn]
  }
}

resource "aws_iam_policy" "eks_cluster_role_assumer" {
  name   = "EKS-ClusterRoleAssumer-${module.eks.cluster_name}"
  policy = data.aws_iam_policy_document.eks_cluster_role_assumer.json
}
