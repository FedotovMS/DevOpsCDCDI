variable "bucket_name" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
}

variable "force_destroy" {
  description = "Allow force destroy of bucket (for labs)"
  type        = bool
  default     = false
}