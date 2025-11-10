# Зручно віддавати і name, і регіональний домен (умовний "URL") бакета
output "bucket_name" {
  value       = aws_s3_bucket.state.bucket
  description = "S3 bucket name for Terraform state"
}

output "bucket_url" {
  value       = aws_s3_bucket.state.bucket_regional_domain_name
  description = "Regional S3 bucket URL (not website hosting)"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "DynamoDB table for state locking"
}