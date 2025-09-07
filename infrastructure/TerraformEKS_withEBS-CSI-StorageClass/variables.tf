variable "ha" {
  type        = number
  default     = "3"
  description = "High Availabilty Redundancy"
}

variable "vpc_cidrs" {
  description = "vpc cidrs"
  type        = string
}

variable "common_tags" {
  default = {
    owner     = "terraform-eks"
    managedBy = "terraform"
    usage     = "training"
    app_name  = "demo-crm"
  }
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "cluster_version" {
  type = string
}

variable "node_type" {
  type = string
}

variable "github_ssh_private_key" {
  description = "SSH private key for accessing GitHub repositories"
  type        = string
  sensitive   = true
}

variable "sealed_secrets_private_key" {
  description = "Private key for Sealed Secrets controller (base64 encoded)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sealed_secrets_certificate" {
  description = "Certificate for Sealed Secrets controller (base64 encoded)"
  type        = string
  sensitive   = true
  default     = ""
}
