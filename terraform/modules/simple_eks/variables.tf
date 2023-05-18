variable "aws_profile" {
  description = "AWS provile used to connect to EKS cluster. As this module is using assume role, please create a new asume role profile from the existing aws profile for the environment with name env-name-k8s and add the following to your ~/.aws/credentials file: \n\n[`env-name`-k8s] \n\n role_arn = arn:aws:iam::`aws-account-id`:role/eks-system-admin-`cluster-name` \n\n source_profile = `env-name` \n\n"
  type        = string
  default     = "dummy-profile-001"
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "key_pair_name" {
  type = string
}

variable "db_instance_type" {
  type = string
}

variable "db_backup_instance_type" {
  type = string
}

variable "server_instance_type" {
  type = string
}

variable "server_instance_count" {
  type = number
}

variable "worker_instance_type" {
  type = string
}

variable "worker_instance_count" {
  type = number
}

variable "metabase_instance_type" {
  type = string
}

variable "metabase_instance_count" {
  type = number
}

variable "cache_redis_instance_type" {
  type = string
}

variable "worker_redis_instance_type" {
  type = string
}

variable "default_nodepool_instance_type" {
  type = string
}

variable "default_nodepool_instance_count" {
  type = number
}

variable "default_nodepool_instance_extra_labels" {
  type    = map(string)
  default = {}
}
