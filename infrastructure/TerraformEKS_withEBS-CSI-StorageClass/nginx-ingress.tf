# ========================================
# NGINX Ingress Controller Configuration
# ========================================

# Deploy NGINX Ingress Controller using Helm
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.13.0"

  values = [
    yamlencode({
      controller = {
        # Enable metrics but disable ServiceMonitor (no Prometheus installed)
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = false
          }
        }

        # Keep default resources (100m CPU, 90Mi memory)
        # Keep default replicas (1)
        # Keep default service type (LoadBalancer)
        # Keep default image and other settings
      }
    })
  ]

  # Ensure EKS cluster is ready before deploying
  depends_on = [
    module.eks,
    module.eks_blueprints_addons
  ]

  # Add timeout for deployment
  timeout = 600

  # Wait for deployment to be ready
  wait = true
}

# Optional: Create a namespace resource for better control (alternative to create_namespace = true)
# resource "kubernetes_namespace" "ingress_nginx" {
#   metadata {
#     name = "ingress-nginx"
#     labels = {
#       "app.kubernetes.io/name"     = "ingress-nginx"
#       "app.kubernetes.io/part-of"  = "ingress-nginx"
#     }
#   }
#   depends_on = [module.eks]
# }
