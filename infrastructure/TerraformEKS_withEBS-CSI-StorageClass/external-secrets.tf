# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# External Secrets Operator
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets-system"
  create_namespace = true
  version          = "0.9.20"

  depends_on = [module.eks]

  values = [
    yamlencode({
      installCRDs = true
      webhook = {
        port = 9443
      }
    })
  ]
}

# IAM role for External Secrets Operator
resource "aws_iam_role" "external_secrets_role" {
  name = "${module.eks.cluster_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = [
              "system:serviceaccount:external-secrets-system:external-secrets",
              "system:serviceaccount:default:external-secrets"
            ]
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM policy for accessing Secrets Manager
resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${module.eks.cluster_name}-external-secrets-policy"
  description = "Policy for External Secrets Operator to access AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:blackjack/*"
        ]
      }
    ]
  })

  tags = var.common_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "external_secrets_policy_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}

# Service Account for External Secrets Operator in external-secrets-system namespace
resource "kubectl_manifest" "external_secrets_service_account_system" {
  depends_on = [helm_release.external_secrets]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "external-secrets"
      namespace = "external-secrets-system"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
      }
    }
  })
}

# Service Account for External Secrets Operator in default namespace
resource "kubectl_manifest" "external_secrets_service_account_default" {
  depends_on = [helm_release.external_secrets]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "external-secrets"
      namespace = "default"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
      }
    }
  })
}

# SecretStore for AWS Secrets Manager
resource "kubectl_manifest" "aws_secret_store" {
  depends_on = [
    helm_release.external_secrets,
    kubectl_manifest.external_secrets_service_account_default
  ]

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "aws-secrets-manager"
      namespace = "default"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name = "external-secrets"
              }
            }
          }
        }
      }
    }
  })
}

# External Secret for MongoDB credentials
resource "kubectl_manifest" "mongodb_external_secret" {
  depends_on = [kubectl_manifest.aws_secret_store]

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "mongodb-secret"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "SecretStore"
      }
      target = {
        name = "mongodb-secret"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "mongodb-root-username"
          remoteRef = {
            key      = "blackjack/mongodb/credentials"
            property = "mongodb-root-username"
          }
        },
        {
          secretKey = "mongodb-root-password"
          remoteRef = {
            key      = "blackjack/mongodb/credentials"
            property = "mongodb-root-password"
          }
        },
        {
          secretKey = "mongodb-replica-set-key"
          remoteRef = {
            key      = "blackjack/mongodb/credentials"
            property = "mongodb-replica-set-key"
          }
        }
      ]
    }
  })
}

# External Secret for MongoDB connection
resource "kubectl_manifest" "mongo_external_secret" {
  depends_on = [kubectl_manifest.aws_secret_store]

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "mongo-secret"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "SecretStore"
      }
      target = {
        name = "mongo-secret"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "mongo-uri"
          remoteRef = {
            key      = "blackjack/mongodb/connection"
            property = "mongo-uri"
          }
        }
      ]
    }
  })
}
