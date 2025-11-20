terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


module "vpc" {
  source = "./modules/vpc"

  vpc_name       = "lesson-7-vpc"
  vpc_cidr_block = "10.0.0.0/16"

  availability_zones = [
    "eu-north-1a",
    "eu-north-1b",
    "eu-north-1c",
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
}

# ECR для Django
module "ecr" {
  source = "./modules/ecr"

  repository_name = "lesson-5-ecr"
}

# EKS кластер
module "eks" {
  source = "./modules/eks"

  cluster_name    = "django-eks-cluster"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}