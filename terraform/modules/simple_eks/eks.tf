module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  kms_key_enable_default_policy = true
  
  cluster_addons = {
    coredns = {
      addon_version : var.cluster_addon_coredns_version
    }
    kube-proxy = {
      addon_version : var.cluster_addon_kubeproxy_version
    }
    vpc-cni = {
      addon_version : var.cluster_addon_vpccni_version
    }
    aws-ebs-csi-driver = {
      addon_version : var.cluster_addon_awsebscsidriver_version
      service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnets
  control_plane_subnet_ids = var.subnets

  eks_managed_node_group_defaults = {
    disk_size  = var.nodepool_disk_size
    subnet_ids = var.nodepool_subnet_ids
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.eks_system_admin.arn}"
      username = "${aws_iam_role.eks_system_admin.name}"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_groups = merge(
    {
      for group in var.managed_node_groups : group.name => {
        create = group.create

        min_size     = group.min_size
        max_size     = group.max_size
        desired_size = group.desired_size

        labels = group.labels

        instance_types = group.instance_types
        capacity_type  = "ON_DEMAND"
        subnet_ids     = group.subnet_ids

        use_custom_launch_template = group.use_custom_launch_template
        remote_access              = group.remote_access

        tags = group.tags
      }
    },

    # Static node groups
    # TODO: Move these to dynamic variable based node groups
    {
      db = {
        create = var.db_instance_enable

        min_size     = var.db_instance_count
        max_size     = var.db_instance_count
        desired_size = var.db_instance_count

        labels = merge(
          {
            role-db = "true"
          },
          var.db_instance_extra_labels
        )

        instance_types = [var.db_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      db2 = {
        create = var.db2_instance_enable

        min_size     = var.db2_instance_count
        max_size     = var.db2_instance_count
        desired_size = var.db2_instance_count

        labels = merge(
          {
            role-db = "true"
          },
          var.db2_instance_extra_labels
        )

        instance_types = [var.db2_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      db_backup = {
        create = var.db_backup_instance_enable

        min_size     = var.db_backup_instance_count
        max_size     = var.db_backup_instance_count
        desired_size = var.db_backup_instance_count

        labels = merge(
          {
            role-db-backup = "true"
          },
          var.db_backup_instance_extra_labels
        )

        instance_types = [var.db_backup_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      server = {
        create = var.server_instance_enable

        min_size     = var.server_instance_count
        max_size     = var.server_instance_count
        desired_size = var.server_instance_count

        labels = merge(
          {
            role-server = "true"
          },
          var.server_instance_extra_labels
        )

        instance_types = [var.server_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      server2 = {
        create = var.server2_instance_enable

        min_size     = var.server2_instance_count
        max_size     = var.server2_instance_count
        desired_size = var.server2_instance_count

        labels = merge(
          {
            role-server = "true"
          },
          var.server2_instance_extra_labels
        )

        instance_types = [var.server2_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      worker = {
        create = var.worker_instance_enable

        min_size     = var.worker_instance_count
        max_size     = var.worker_instance_count
        desired_size = var.worker_instance_count

        labels = merge(
          {
            role-worker = "true"
            role-cron   = "true"
          },
          var.worker_instance_extra_labels
        )

        instance_types = [var.worker_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      metabase = {
        create = var.metabase_instance_enable

        min_size     = var.metabase_instance_count
        max_size     = var.metabase_instance_count
        desired_size = var.metabase_instance_count

        labels = merge(
          {
            role-metabase = "true"
          },
          var.metabase_instance_extra_labels
        )

        instance_types = [var.metabase_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      cache_redis = {
        create = var.cache_redis_instance_enable

        min_size     = 1
        max_size     = 1
        desired_size = 1

        labels = merge(
          {
            role-cache-redis = "true"
          },
          var.cache_redis_instance_extra_labels
        )

        instance_types = [var.cache_redis_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      cache_redis2 = {
        create = var.cache_redis2_instance_enable

        min_size     = 1
        max_size     = 1
        desired_size = 1

        labels = merge(
          {
            role-cache-redis = "true"
          },
          var.cache_redis_instance_extra_labels
        )

        instance_types = [var.cache_redis2_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      worker_redis = {
        create = var.worker_redis_instance_enable

        min_size     = 1
        max_size     = 1
        desired_size = 1

        labels = merge(
          {
            role-worker-redis = "true"
          },
          var.worker_redis_instance_extra_labels
        )

        instance_types = [var.worker_redis_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
      }

      default = {
        create = var.default_nodepool_instance_enable

        min_size     = var.default_nodepool_instance_count
        max_size     = var.default_nodepool_instance_count
        desired_size = var.default_nodepool_instance_count

        labels = merge(
          {
            role-default = "true"
          },
          var.default_nodepool_instance_extra_labels
        )

        instance_types = [var.default_nodepool_instance_type]
        capacity_type  = "ON_DEMAND"

        use_custom_launch_template = false

        remote_access = {
          ec2_ssh_key = var.key_pair_name
        }
    } }
  )
  tags = var.tags
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks.eks_managed_node_groups, #TODO: Chek if this is causing auth failure issues sometimes
  ]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # token                  = data.aws_eks_cluster_auth.default.token

  # Issue: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
  }
}
