# Sealed Secrets key management to ensure consistent encryption across cluster recreations
resource "kubectl_manifest" "sealed_secrets_key" {
  count = var.sealed_secrets_private_key != "" ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "sealed-secrets-key"
      namespace = "kube-system"
      labels = {
        "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
      }
    }
    type = "kubernetes.io/tls"
    data = {
      "tls.crt" = var.sealed_secrets_certificate
      "tls.key" = var.sealed_secrets_private_key
    }
  })

  depends_on = [
    helm_release.sealed_secrets
  ]
}

# Output the public key for reference
output "sealed_secrets_public_key" {
  description = "Public key for sealing secrets (base64 encoded)"
  value       = var.sealed_secrets_certificate
  sensitive   = true
}
