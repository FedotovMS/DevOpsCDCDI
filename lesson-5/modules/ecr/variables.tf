variable "ecr_name" {
  description = "ECR repository name"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "immutable_tags" {
  description = "Make image tags immutable (recommended for prod)"
  type        = bool
  default     = false
}

variable "expire_untagged_after_days" {
  description = "Lifecycle: expire untagged images after N days (0 = disable)"
  type        = number
  default     = 14
}