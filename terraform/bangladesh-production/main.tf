terraform {
  required_version = "1.4.6"

  backend "s3" {
    bucket         = "simple-server-bangladesh-terraform-state"
    key            = "k8s.production.terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "k8s-production-terraform-lock"
    profile        = "bangladesh"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

locals {
  env        = "production"
  deployment = "k8s"
  service    = "simple"
  tags = {
    Environment = local.env
    Terraform   = "true"
    Service     = local.service
    Deployment  = local.deployment
  }
  # Note: Add contry name prefix to the future environments to avoid conflict with existing resources. We missed it for this environment.
  vpc_name                 = "${local.env}-${local.service}-vpc-01"
  key_pair_name            = "${local.env}-${local.service}-${local.deployment}"
  cluster_name             = "${local.env}-${local.service}-${local.deployment}-01"
  db_backup_s3_bucket_name = "${local.env}-${local.service}-${local.deployment}-db-backup"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "bangladesh"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "172.30.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["172.30.1.0/24", "172.30.2.0/24", "172.30.3.0/24"]
  public_subnets  = ["172.30.101.0/24", "172.30.102.0/24", "172.30.103.0/24"]

  enable_nat_gateway     = true
  enable_vpn_gateway     = true
  one_nat_gateway_per_az = true

  tags = local.tags
}

resource "aws_key_pair" "simple_aws_key" {
  key_name   = local.key_pair_name
  public_key = file("~/.ssh/simple_aws_key.pub") # Get it from password store
}

module "eks" {
  source = "../modules/simple_eks"

  subnets       = module.vpc.private_subnets
  vpc_id        = module.vpc.vpc_id
  cluster_name  = local.cluster_name
  tags          = local.tags
  key_pair_name = aws_key_pair.simple_aws_key.key_name

  aws_profile = "bangladesh-k8s-production"

  nodepool_subnet_ids = [module.vpc.private_subnets[0]] # Use single zone avoid volume mount issues during node replacement
  nodepool_disk_size  = 50

  db_instance_type  = "t3.medium"
  db_instance_count = 2

  db_backup_instance_type = "t3.small"

  server_instance_type  = "t3.xlarge"
  server_instance_count = 2

  worker_instance_type  = "t3.xlarge"
  worker_instance_count = 1

  metabase_instance_type  = "t3.small"
  metabase_instance_count = 1

  cache_redis_instance_type  = "t3.small"
  worker_redis_instance_type = "t3.small"

  default_nodepool_instance_type  = "t3.medium"
  default_nodepool_instance_count = 3
  default_nodepool_instance_extra_labels = {
    "role-ingress" = "true"
  }
}

module "db_backup_s3_bucket" {
  source      = "../modules/simple_s3"
  bucket_name = local.db_backup_s3_bucket_name
  tags        = local.tags
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

output "db_backup_s3_bucket_id" {
  value = module.db_backup_s3_bucket.bucket_id
}

output "db_backup_s3_bucket_arn" {
  value = module.db_backup_s3_bucket.bucket_arn
}

output "db_backup_s3_user_arn" {
  value = module.db_backup_s3_bucket.bucket_arn
}

output "db_backup_s3_access_key" {
  value = module.db_backup_s3_bucket.access_key
}

output "db_backup_s3_access_secret" {
  value     = module.db_backup_s3_bucket.access_secret
  sensitive = true
}
