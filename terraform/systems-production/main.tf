terraform {
  required_version = "1.4.6"

  backend "s3" {
    bucket         = "simple-server-development-terraform-state"
    key            = "systems-production.terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "systems-production-terraform-lock"
    profile        = "development"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

locals {
  env     = "production"
  service = "systems"
  tags = {
    Environment = local.env
    Terraform   = "true"
    Service     = local.service
  }
  vpc_name      = "${local.service}-${local.env}-vpc-01"
  key_pair_name = "${local.service}-${local.env}"
  cluster_name  = "${local.service}-${local.env}-01"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "development"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = local.vpc_name
  cidr = "172.28.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["172.28.1.0/24", "172.28.2.0/24"]
  public_subnets  = ["172.28.101.0/24", "172.28.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  tags = local.tags
}

resource "aws_key_pair" "simple_aws_key" {
  key_name   = local.key_pair_name
  public_key = file("~/.ssh/simple_aws_key.pub") # Retrieve it from 1Password under the name 'AWS Master SSH Key'. Only the public key is needed.
}

module "eks" {
  source = "../modules/simple_eks"

  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_name    = local.cluster_name
  cluster_version = "1.31"
  tags            = local.tags
  key_pair_name   = aws_key_pair.simple_aws_key.key_name

  aws_profile = "${local.service}-${local.env}"

  cluster_addon_coredns_version         = "v1.10.1-eksbuild.2"
  cluster_addon_kubeproxy_version       = "v1.28.1-eksbuild.1"
  cluster_addon_vpccni_version          = "v1.14.1-eksbuild.1"
  cluster_addon_awsebscsidriver_version = "v1.25.0-eksbuild.1"

  nodepool_subnet_ids = [module.vpc.private_subnets[0]] # Use only one subnet for nodepool
  nodepool_disk_size  = 50

  managed_node_groups = [
    {
      name         = "default-03"
      create       = true
      min_size     = 2
      max_size     = 2
      desired_size = 2

      use_custom_launch_template = false
      remote_access = {
        ec2_ssh_key = local.key_pair_name
      }

      labels = {
        role-default = "true"
      }
      instance_types = ["c6a.xlarge"]
      subnet_ids     = [module.vpc.private_subnets[0]]
      tags = {
        Service    = "shared"
        Deployment = "k8s"
      }
    }
  ]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_assume_role_arn" {
  value = module.eks.assume_role_arn
}
