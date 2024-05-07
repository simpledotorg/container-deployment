terraform {
  required_version = "1.4.6"

  backend "s3" {
    bucket         = "simple-server-india-terraform-state-02"
    key            = "k8s.production.terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "simple-india-production-terraform-lock"
    profile        = "india"
  }

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
  vpc_name                   = "${local.region}-${local.env}-${local.service}-vpc-01"
  key_pair_name              = "${local.region}-${local.env}-${local.service}-${local.deployment}"
  cluster_name               = "${local.region}-${local.env}-${local.service}-${local.deployment}-01"
  db_backup_s3_bucket_name   = "${local.region}-${local.env}-${local.service}-${local.deployment}-db-backup"
  log_archive_s3_bucket_name = "${local.region}-${local.env}-${local.service}-${local.deployment}-archived-logs"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "india"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "172.29.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["172.29.1.0/24", "172.29.2.0/24"]
  public_subnets  = ["172.29.101.0/24", "172.29.102.0/24"]

  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = true

  tags = local.tags
}

resource "aws_key_pair" "simple_aws_key" {
  key_name   = local.key_pair_name
  public_key = file("~/.ssh/simple_aws_key.pub") # Get it from password store
}

module "eks" {
  source = "../modules/simple_eks"

  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_name    = local.cluster_name
  cluster_version = "1.28"
  tags            = local.tags
  key_pair_name   = aws_key_pair.simple_aws_key.key_name

  aws_profile = "india-k8s-production"

  cluster_addon_coredns_version         = "v1.8.7-eksbuild.7"
  cluster_addon_kubeproxy_version       = "v1.24.17-eksbuild.2"
  cluster_addon_vpccni_version          = "v1.15.1-eksbuild.1"
  cluster_addon_awsebscsidriver_version = "v1.26.1-eksbuild.1"

  nodepool_subnet_ids = [module.vpc.private_subnets[0]] # Use only one subnet for nodepool
  nodepool_disk_size  = 50

  db_instance_enable = false

  db2_instance_enable = true
  db2_instance_type   = "t3a.2xlarge"
  db2_instance_count  = 2
  db2_instance_extra_labels = {
    role-db-backup = "true"
  }

  server2_instance_enable = true
  server2_instance_type   = "c6a.2xlarge"
  server2_instance_count  = 2
  server2_instance_extra_labels = {
    "role-ingress"  = "true"
    "role-metabase" = "true"
    "role-worker"   = "true"
  }

  cache_redis_instance_enable = true
  cache_redis_instance_type   = "r5a.xlarge"

  cache_redis2_instance_enable = false
  cache_redis2_instance_type   = "r5a.large"

  default_nodepool_instance_enable = true
  default_nodepool_instance_count  = 1
  default_nodepool_instance_type   = "t3a.small"
  default_nodepool_instance_extra_labels = {
    "role-cron" = "true"
  }
}

module "db_backup_s3_bucket" {
  source       = "../modules/simple_s3"
  bucket_name  = local.db_backup_s3_bucket_name
  tags         = local.tags
  allowed_vpcs = [module.vpc.vpc_id]
}

module "log_archive_s3_bucket" {
  source       = "../modules/simple_s3"
  bucket_name  = local.log_archive_s3_bucket_name
  tags         = local.tags
  allowed_vpcs = [module.vpc.vpc_id]
}

# in-prod-s3-gateway-endpoint-02 was manually created from the AWS console
# This allows direct access from pods/EC2 to S3, thus reducing data transfer costs via NAT

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


output "log_archive_s3_bucket_id" {
  value = module.log_archive_s3_bucket.bucket_id
}

output "log_archive_s3_bucket_arn" {
  value = module.log_archive_s3_bucket.bucket_arn
}

output "log_archive_s3_user_arn" {
  value = module.log_archive_s3_bucket.bucket_arn
}

output "log_archive_s3_access_key" {
  value = module.log_archive_s3_bucket.access_key
}

output "log_archive_s3_access_secret" {
  value     = module.log_archive_s3_bucket.access_secret
  sensitive = true
}
