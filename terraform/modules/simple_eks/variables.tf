variable "aws_profile" {
  description = "AWS provile used to connect to EKS cluster. As this module is using assume role, please create a new asume role profile from the existing aws profile for the environment with name env-name-k8s and add the following to your ~/.aws/credentials file: \n\n[`env-name`-k8s] \n\n role_arn = arn:aws:iam::`aws-account-id`:role/eks-system-admin-`cluster-name` \n\n source_profile = `env-name` \n\n"
  type        = string
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

variable "db_instance_count" {
  type = number
}

variable "db_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "db2_instance_enable" {
  type    = bool
  default = false
}

variable "db2_instance_type" {
  type    = string
  default = ""
}

variable "db2_instance_count" {
  type    = number
  default = 0
}

variable "db2_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "db_backup_instance_type" {
  type    = string
  default = "t3.small"
}

variable "db_backup_instance_enable" {
  type    = bool
  default = true
}

variable "db_backup_instance_count" {
  type    = number
  default = 1
}

variable "db_backup_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "server_instance_type" {
  type = string
}

variable "server_instance_count" {
  type = number
}

variable "server_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "server2_instance_enable" {
  type    = bool
  default = false
}

variable "server2_instance_type" {
  type    = string
  default = ""
}

variable "server2_instance_count" {
  type    = number
  default = 0
}

variable "server2_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "worker_instance_type" {
  type = string
}

variable "worker_instance_count" {
  type = number
}

variable "worker_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "metabase_instance_type" {
  type = string
}

variable "metabase_instance_count" {
  type = number
}

variable "metabase_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "cache_redis_instance_type" {
  type = string
}

variable "cache_redis_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "worker_redis_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_redis_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "worker_redis_instance_enable" {
  type    = bool
  default = true
}

variable "default_nodepool_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "default_nodepool_instance_count" {
  type    = number
  default = 1
}

variable "default_nodepool_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "default_nodepool_instance_enable" {
  type    = bool
  default = true
}

variable "nodepool_disk_size" {
  type    = number
  default = 20 # GB
}

variable "nodepool_subnet_ids" {
  description = "Subnet IDs for the nodepool. Use single zone avoid volume mount issues during node replacement"
  type        = list(string)
}
