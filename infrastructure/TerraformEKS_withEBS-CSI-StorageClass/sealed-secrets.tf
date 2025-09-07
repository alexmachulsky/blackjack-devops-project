resource "helm_release" "sealed_secrets" {
  name      = "sealed-secrets"
  namespace = "kube-system"

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.17.3" # You can check for the latest version

  create_namespace = true
}
