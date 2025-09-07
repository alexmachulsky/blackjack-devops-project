
resource "helm_release" "argocd" {
  name             = "my-argo-cd" # or just "argocd" if you prefer
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  # Optional: lock to a specific version, or remove for latest
  #version = "6.7.16"
  version = "8.1.2"
  # Optional: if you want to provide custom values, uncomment:
  # values = [file("${path.module}/argocd-values.yaml")]
}

# App-of-apps deployment - managed manually via kubectl
# resource "kubectl_manifest" "app-of-apps" {
#   yaml_body = file("./app-of-apps.yaml")
#   depends_on = [helm_release.argocd]
# }
