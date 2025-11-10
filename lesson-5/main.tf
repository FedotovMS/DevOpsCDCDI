provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "demo_sg" {
  name = "demo-sg"
  description = "allow ssh"


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "demo" {
  ami = "ami-07fb0a5bf9ae299a4"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
}

###############################
# 1) S3 + DynamoDB для стейту
###############################
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.state_bucket_name
  table_name  = var.state_lock_table_name
}

###############################
# 2) VPC
###############################
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name = var.vpc_name
}

###############################
# 3) ECR
###############################
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = var.ecr_scan_on_push
}