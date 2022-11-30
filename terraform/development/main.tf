variable "aws_region" {
  default = "ap-south-1"
}

locals {
  qa_server_count      = 3
  qa_server_name_sufix = "k3s-qa"
}

terraform {
  required_version = "~> 1.3.5"

  backend "s3" {
    bucket         = "simple-server-development-terraform-state"
    key            = "k8s.development.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "k8s.terraform-lock"
    profile        = "development"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "development"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

module "k8s_server_sg_qa" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = "${local.qa_server_name_sufix}-sg"
  description = "Security group for k8s servers"

  # Allow all traffic within k8s instances
  ingress_with_self = [
    { rule = "all-all" }
  ]

  # Allow all egress traffic
  egress_rules = ["all-all"]

  # Other port specific rules
  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "k8s_server_qa" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.2.1"

  count = local.qa_server_count

  name = format("simple-server-%s-%03d", local.qa_server_name_sufix, count.index + 1)

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = "simple-server"
  monitoring                  = true
  associate_public_ip_address = true
  vpc_security_group_ids = [
    module.k8s_server_sg_qa.security_group_id
  ]
  subnet_id = "subnet-dea591b6"

  tags = {
    Terraform   = "true"
    Environment = "qa"
  }

  root_block_device = [
    {
      "volume_size" : "100"
    }
  ]
}

# Attach elastic ip to avoid public ip change during reboot
resource "aws_eip_association" "eip_assoc_qa" {
  count         = local.qa_server_count
  instance_id   = module.k8s_server_qa[count.index].id
  allocation_id = aws_eip.eip_qa[count.index].allocation_id
}

resource "aws_eip" "eip_qa" {
  count = local.qa_server_count
  vpc   = true
}

# QA outputs
output "k8s_server_qa_id" {
  value = module.k8s_server_qa.*.id
}

output "k8s_server_qa_public_ip" {
  value = aws_eip_association.eip_assoc_qa.*.public_ip
}

output "k8s_server_qa_private_ip" {
  value = module.k8s_server_qa.*.private_ip
}

output "k8s_server_qa_sg_id" {
  value = module.k8s_server_sg_qa.security_group_id
}
