locals {
  profile = "development"
  region  = "ap-south-1"
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

terraform {
  required_version = "1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "aws" {
  region  = local.region
  profile = local.profile
}

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver-${module.eks.cluster_name}"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


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

resource "aws_iam_policy" "eks_console_access" {
  name = "EKSConsoleAccess"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "developer_eks_console_access" {
  role       = aws_iam_role.eks_system_admin.name
  policy_arn = aws_iam_policy.eks_console_access.arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = "my-cluster-01"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      version : "v1.8.7-eksbuild.3"
    }
    kube-proxy = {
      version : "v1.24.7-eksbuild.2"
    }
    vpc-cni = {
      version : "v1.11.4-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      version : "v1.18.0-eksbuild.1"
      service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnets
  control_plane_subnet_ids = var.subnets

  eks_managed_node_group_defaults = {
    instancdisk_size = 100
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.eks_system_admin.arn}"
      username = "${aws_iam_role.eks_system_admin.name}"
      groups   = ["system:masters"]
    },
  ]

  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      labels = {
        role = "general"
      }

      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = "simple-server"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# TODO: Eanble auth managment
# TODO: Add VPC
# TODO: Use ALB with ngins ingress controller
# TODO: Boot strap arogcd
