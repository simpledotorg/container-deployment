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
