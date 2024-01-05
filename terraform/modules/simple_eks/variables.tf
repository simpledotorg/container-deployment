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

variable "cluster_version" {
  type    = string
  default = "1.24"
}

variable "tags" {
  type = map(string)
}

variable "key_pair_name" {
  type = string
}

variable "db_instance_enable" {
  type    = bool
  default = false
}

variable "db_instance_type" {
  type    = string
  default = ""
}

variable "db_instance_count" {
  type    = number
  default = 0
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
  default = ""
}

variable "db_backup_instance_enable" {
  type    = bool
  default = false
}

variable "db_backup_instance_count" {
  type    = number
  default = 0
}

variable "db_backup_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "server_instance_enable" {
  type    = bool
  default = false
}

variable "server_instance_type" {
  type    = string
  default = ""
}

variable "server_instance_count" {
  type    = number
  default = 0
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

variable "worker_instance_enable" {
  type    = bool
  default = false
}

variable "worker_instance_type" {
  type    = string
  default = ""
}

variable "worker_instance_count" {
  type    = number
  default = 0
}

variable "worker_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "metabase_instance_enable" {
  type    = bool
  default = false
}

variable "metabase_instance_type" {
  type    = string
  default = ""
}

variable "metabase_instance_count" {
  type    = number
  default = 0
}

variable "metabase_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "cache_redis_instance_enable" {
  type    = bool
  default = false
}

variable "cache_redis_instance_type" {
  type    = string
  default = ""
}

variable "cache_redis_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "cache_redis2_instance_enable" {
  type    = bool
  default = false
}

variable "cache_redis2_instance_type" {
  type    = string
  default = ""
}

variable "cache_redis2_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "worker_redis_instance_type" {
  type    = string
  default = ""
}

variable "worker_redis_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "worker_redis_instance_enable" {
  type    = bool
  default = false
}

variable "default_nodepool_instance_type" {
  type    = string
  default = ""
}

variable "default_nodepool_instance_count" {
  type    = number
  default = 0
}

variable "default_nodepool_instance_extra_labels" {
  type    = map(string)
  default = {}
}

variable "default_nodepool_instance_enable" {
  type    = bool
  default = false
}

variable "nodepool_disk_size" {
  type    = number
  default = 20 # GB
}

variable "nodepool_subnet_ids" {
  description = "Subnet IDs for the nodepool. Use single zone avoid volume mount issues during node replacement"
  type        = list(string)
}
