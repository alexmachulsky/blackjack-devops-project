# Blackjack Terraform Infrastructure

> **Infrastructure as Code for AWS** – Automated provisioning of EKS, VPC, EBS CSI, and all network/storage needed for the Blackjack SaaS application.  
> Built with [Terraform](https://www.terraform.io/).

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Modules](#modules)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Managing State](#managing-state)
- [Outputs](#outputs)
- [Contact](#contact)

---

## Overview

This repo contains **infrastructure as code** (IaC) for AWS using [Terraform](https://www.terraform.io/).  
It provisions VPC/networking, an EKS cluster, and dynamic storage (EBS CSI) for the complete cloud-native Blackjack stack.

### **Key Features**

- Automated AWS resource creation and clean-up
- Modular design (network, storage) for reusability and clarity
- Supports production/staging environments and remote state
- Output of all key connection values for quick Kubernetes setup

---

## Repository Structure

```bash
blackjack-terraform/
├── README.md
└── TerraformEKS_withEBS-CSI-StorageClass/
    ├── MAIN.tf                  # Core resource orchestration
    ├── providers.tf             # Provider and backend config
    ├── terraform.tfvars         # Custom variable values (do not commit secrets!)
    ├── outputs.tf               # All infrastructure outputs
    ├── variables.tf             # Input variables for modules/resources
    ├── sealed-secrets.tf        # Sealed Secrets controller (optional)
    ├── argocd.tf                # ArgoCD deployment (optional)
    ├── app-of-apps.yaml         # For GitOps bootstrap (optional)
    ├── modules/
    │   ├── ebs-csi-storageclass/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── provider.tf
    │   │   └── variables.tf
    │   └── network/
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── terraform.tfstate        # Local state file (gitignore this)
    ├── terraform.tfstate.backup # Local state backup (gitignore)
    ├── tfplan                   # Saved plan output (optional)
```

---

## Modules

- **modules/ebs-csi-storageclass/**  
  Deploys the AWS EBS CSI driver for dynamic volume provisioning in EKS.
- **modules/network/**  
  Manages custom VPC, subnets, and all required networking.

---

## Prerequisites

- [Terraform v1.4+](https://www.terraform.io/downloads)
- AWS account and credentials (`aws configure`)
- IAM user or role with rights to create/manage EKS, VPC, IAM, ECR, and storage

---

## Getting Started

### 1. Initialize Terraform

Install dependencies and modules:

```bash
cd TerraformEKS_withEBS-CSI-StorageClass
terraform init
```

### 2. Update variables in `terraform.tfvars`

Set:
- `region`
- `tag_owner` or other tags for your environment
- `node_type` and other instance parameters

### 3. Plan and Apply

```bash
terraform apply
```
Type `yes` when prompted.

### 4. Connect your kubectl CLI

After apply, you'll see an output named `cluster_connect`.  
Copy and run the provided command to configure `kubectl` for your new EKS cluster.

---

## Managing State

By default, state is local (`terraform.tfstate`).  
**Best practice for production or teamwork:**  
Configure remote state with S3 + DynamoDB, for locking and history.

Example in `providers.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "terraform-lock"
  }
}
```
*Make sure to create the S3 bucket and DynamoDB table before running `terraform init` with this config.*

---

## Outputs

After running `terraform apply`:

```bash
terraform output
```

Example output:
```hcl
SG = {
  "cluster_primary_security_group_id" = "sg-0abcdef1234567890"
  "cluster_security_group_id" = "sg-0fedcba9876543210"
  "node_security_group_id" = "sg-0123456789abcdef0"
}
cluster_connect = "aws eks update-kubeconfig --region <region> --name <cluster-name>"
cluster_endpoint = "https://EXAMPLE1234567890.gr7.<region>.eks.amazonaws.com"
```
- **SG:** Security group IDs for EKS and nodes
- **cluster_connect:** `kubectl` config command
- **cluster_endpoint:** EKS API endpoint

You can always run `terraform output` to see current values.

---

## Contact

Alex Machulsky  
[LinkedIn](https://www.linkedin.com/in/alex-machulsky-/)  
[GitHub](https://github.com/alexmachulsky)
