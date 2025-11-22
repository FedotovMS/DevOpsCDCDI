output "argo_cd_server_service" {
  value       = "argo-cd.${var.namespace}.svc.cluster.local"
}

output "admin_password" {
  value       = "Run: kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}