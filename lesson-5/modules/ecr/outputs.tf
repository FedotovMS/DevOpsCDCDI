output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "Full ECR repo URL (account.dkr.ecr.region.amazonaws.com/repo)"
}

output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "ECR repository ARN"
}