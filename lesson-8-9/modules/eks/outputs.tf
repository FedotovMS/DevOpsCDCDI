output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_id" {
  description = "EKS cluster name/id"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "openid_connect_provider_arn" {
  description = "The ARN of the OIDC Provider for the cluster"
  value       = module.eks.oidc_provider_arn
}