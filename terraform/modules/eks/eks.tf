module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = var.cluster_name
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

  eks_managed_node_groups = {
    db = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      labels = {
        role-db = "true"
      }

      instance_types = [var.db_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    server = {
      min_size     = var.server_instance_count
      max_size     = var.server_instance_count
      desired_size = var.server_instance_count

      labels = {
        role-server = "true"
      }

      instance_types = [var.server_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    worker = {
      min_size     = var.worker_instance_count
      max_size     = var.worker_instance_count
      desired_size = var.worker_instance_count

      labels = {
        role-worker = "true"
      }

      instance_types = [var.worker_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    metabase = {
      min_size     = var.metabase_instance_count
      max_size     = var.metabase_instance_count
      desired_size = var.metabase_instance_count

      labels = {
        role-metabase = "true"
      }

      instance_types = [var.metabase_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    cache_redis = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      labels = {
        role-cache-redis = "true"
      }

      instance_types = [var.cache_redis_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    worker_redis = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      labels = {
        role-worker-redis = "true"
      }

      instance_types = [var.worker_redis_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }

    default = {
      min_size     = var.default_nodepool_instance_count
      max_size     = var.default_nodepool_instance_count
      desired_size = var.default_nodepool_instance_count

      labels = {
        role-default = "true"
      }

      instance_types = [var.default_nodepool_instance_type]
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_pair_name
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}
