module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

 
  vpc_id     = var.vpc_id
  subnet_ids = concat(var.private_subnets, var.public_subnets)

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 2

      instance_types = ["t3.micro"]
    }
  }
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_endpoint_public_access_cidrs = [
    "0.0.0.0/0"
  ]
    enable_cluster_creator_admin_permissions = true
}