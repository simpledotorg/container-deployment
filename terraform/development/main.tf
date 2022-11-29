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

module "k8s_server_qa" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  count = local.qa_server_count

  name = format("simple-server-%s-%03d", local.qa_server_name_sufix, count.index + 1)

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = "simple-server"
  monitoring                  = true
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "sg-0846a983060a48121",
    "sg-05cb8fd0ec3b6120d",
    "sg-069238f5efa92bae5",
    "sg-033da50a0726b041c",
    "sg-0a94d4ba83cf3437c"
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

output "k8s_server_qa_id" {
  value = module.k8s_server_qa.*.id
}

output "k8s_server_qa_public_ip" {
  value = aws_eip_association.eip_assoc_qa.*.public_ip
}

output "k8s_server_qa_private_ip" {
  value = module.k8s_server_qa.*.private_ip
}
