terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

# Module for S3 bucket and DynamoDB table
# module "s3_backend" {
#   source              = "./modules/s3-backend"
#   s3_bucket_name      = "lesson-7"
#   dynamodb_table_name = "terraform-locks"
# }

# Module for VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c",]
  vpc_name           = "vpc"
}

# Module for ECR
module "ecr" {
  source       = "./modules/ecr"
  repository_name     = "lesson-7-ecr"
  scan_on_push    = true
}

# Module for EKS
module "eks" {
  source          = "./modules/eks"
  cluster_name    = "lesson-7-eks"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
}

# Module to deploy Jenkins on the Kubernetes cluster via Helm
module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.cluster_id

  oidc_provider_arn = module.eks.openid_connect_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  providers = {
    helm = helm
  }
}

# Module to deploy ArgoCD, a GitOps tool, on Kubernetes
module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
}