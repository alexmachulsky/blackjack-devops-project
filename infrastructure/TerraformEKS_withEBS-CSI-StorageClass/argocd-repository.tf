# ========================================
# ArgoCD Repository Configuration
# ========================================

# ArgoCD Repository Secret for GitHub SSH access
resource "kubectl_manifest" "argocd_github_repo" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "github-repo-secret"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    data = {
      type          = base64encode("git")
      url           = base64encode("git@github.com:alexmachulsky/blackjack-k8s.git")
      sshPrivateKey = base64encode(var.github_ssh_private_key)
    }
  })

  depends_on = [helm_release.argocd]
}
