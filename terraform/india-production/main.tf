terraform {
  required_version = "1.4.6"

  # backend "s3" {
  #   bucket         = "simple-server-india-terraform-state"
  #   key            = "k8s.production.terraform.tfstate"
  #   encrypt        = true
  #   region         = "ap-south-1"
  #   dynamodb_table = "k8s-production-terraform-lock"
  #   profile        = "india"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.66.1"
    }
  }
}

locals {
  env        = "prod"
  deployment = "k8s"
  service    = "simple"
  region     = "in"
  tags = {
    Environment = local.env
    Terraform   = "true"
    Service     = local.service
    Deployment  = local.deployment
    Region      = local.region
  }
  vpc_name                 = "${local.region}-${local.env}-${local.service}-vpc-01"
  key_pair_name            = "${local.region}-${local.env}-${local.service}-${local.deployment}"
  cluster_name             = "${local.region}-${local.env}-${local.service}-${local.deployment}-01"
  db_backup_s3_bucket_name = "${local.region}-${local.env}-${local.service}-${local.deployment}-db-backup"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "india"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "172.30.0.0/16"

  azs = ["ap-south-1a", "ap-south-1b"]
  # private_subnets = ["172.30.1.0/24", "172.30.2.0/24"]
  public_subnets = ["172.30.101.0/24", "172.30.102.0/24"]

  enable_nat_gateway     = false
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = true

  tags = local.tags
}

resource "aws_key_pair" "simple_aws_key" {
  key_name   = local.key_pair_name
  public_key = file("~/.ssh/india_simple_aws_key.pub") # Get it from password store
}

module "eks" {
  source = "../modules/simple_eks"

  subnets       = module.vpc.public_subnets
  vpc_id        = module.vpc.vpc_id
  cluster_name  = local.cluster_name
  tags          = local.tags
  key_pair_name = aws_key_pair.simple_aws_key.key_name

  aws_profile = "india-k8s-production"

  nodepool_subnet_ids = [module.vpc.public_subnets[0]] # Use only one subnet for nodepool
  nodepool_disk_size  = 50

  db_instance_type  = "t3.xlarge"
  db_instance_count = 2
  db_instance_extra_labels = {
    role-db-backup = "true"
  }

  db_backup_instance_enable = false

  server_instance_type  = "t3.xlarge"
  server_instance_count = 2
  server_instance_extra_labels = {
    "role-ingress" = "true"
  }

  worker_instance_type  = "t3.large"
  worker_instance_count = 1

  metabase_instance_type  = "t3.small"
  metabase_instance_count = 1

  cache_redis_instance_type    = "r5.large"
  worker_redis_instance_enable = false

  default_nodepool_instance_enable = false
}

module "db_backup_s3_bucket" {
  source      = "../modules/simple_s3"
  bucket_name = local.db_backup_s3_bucket_name
  tags        = local.tags
}

# Log archival bucket and user is reused from old environment
# https://github.com/simpledotorg/deployment/blob/master/terraform/india/main.tf

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
