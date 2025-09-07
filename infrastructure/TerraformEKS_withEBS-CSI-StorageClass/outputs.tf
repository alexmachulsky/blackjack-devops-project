output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "SG" {
  value = {
    "cluster_primary_security_group_id" = module.eks.cluster_primary_security_group_id
    "cluster_security_group_id"         = module.eks.cluster_security_group_id
    "node_security_group_id"            = module.eks.node_security_group_id
  }
}

output "cluster_connect" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "nginx_ingress_load_balancer" {
  description = "The external load balancer hostname/IP for NGINX Ingress Controller"
  value       = "kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
