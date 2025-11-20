# output "instance_public_ip" {
#   value = aws_instance.demo.private_ip
# }

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}