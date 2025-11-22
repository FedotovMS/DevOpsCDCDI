variable "name" {
  type        = string
  default     = "argo_cd"
}

variable "namespace" {
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  type        = string
  default     = "5.46.4"
}