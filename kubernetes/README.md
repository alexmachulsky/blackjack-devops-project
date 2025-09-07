# Blackjack Kubernetes Deployment 🃏

> GitOps-based, declarative Kubernetes deployment for the Blackjack Flask application on AWS EKS, powered by ArgoCD App of Apps pattern.
> Includes MongoDB (replica set), NGINX Ingress, monitoring, EFK logging, and GitOps automation via GitHub Actions.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [ArgoCD GitOps Deployment (App of Apps)](#argocd-gitops-deployment-app-of-apps)
- [Ingress Access](#ingress-access)
- [GitOps Automation](#gitops-automation)
- [Versions](#versions)
- [Cleanup & Redeploy](#cleanup--redeploy)
- [Contact](#contact)

---

## Overview

This repository contains all Helm charts and Kubernetes manifests for deploying the **Blackjack Flask app**, **MongoDB replica set**, **NGINX Ingress**, **monitoring** (Prometheus/Grafana), and **EFK logging** to an AWS EKS cluster.  
All deployments are managed automatically by **ArgoCD** using the [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-of-apps/) pattern, enabling full GitOps automation and declarative infrastructure management.

---

## Repository Structure

```bash
blackjack-k8s/
├── apps/
│   ├── app-of-apps.yaml        # ArgoCD App of Apps root manifest
│   ├── blackjack.yaml          # ArgoCD Application for Blackjack stack
│   ├── efk.yaml                # ArgoCD Application for EFK logging stack
│   └── monitor.yaml            # ArgoCD Application for monitoring stack
├── blackjack-stack/            # Helm umbrella chart (Flask app + MongoDB + ingress)
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── Chart.lock
│   ├── charts/
│   │   ├── blackjack/
│   │   │   ├── Chart.yaml
│   │   │   ├── templates/
│   │   │   └── values.yaml
│   │   ├── blackjack-1.0.0.tgz
│   │   └── mongodb-16.5.24.tgz
│   ├── templates/
│   │   ├── sealed-mongodb-secret.yaml
│   │   └── sealed-mongo-secret.yaml
├── efk-stack/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── Chart.lock
│   ├── charts/
│   │   ├── elasticsearch-22.0.13.tgz
│   │   ├── fluent-bit-3.1.8.tgz
│   │   └── kibana-12.1.5.tgz
├── monitor-stack/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── Chart.lock
│   └── charts/
│       └── kube-prometheus-stack-75.12.0.tgz
└── README.md
```

---

## Prerequisites

- [ArgoCD](https://argo-cd.readthedocs.io/) installed and running in your EKS cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- AWS EKS cluster (with `kubectl` and `aws` CLI configured)
- Proper IAM permissions for ECR, EKS, and GitHub Actions (for GitOps workflow)
- (Optional) [No-IP](https://www.noip.com/) or similar DDNS service for DNS pointing

---

## ArgoCD GitOps Deployment (App of Apps)

### 1. Install ArgoCD (if not already installed)

Follow the [official guide](https://argo-cd.readthedocs.io/en/stable/getting_started/) to deploy ArgoCD in your cluster.

### 2. Bootstrap the entire application stack using App of Apps

Apply the App of Apps manifest:

```bash
kubectl apply -f apps/app-of-apps.yaml -n argocd
```

- ArgoCD will automatically create and sync all child applications (`blackjack-stack`, `efk-stack`, `monitor-stack`, etc.).
- All Helm chart deployments are managed by ArgoCD—**no manual `helm install` required**.

### 3. Monitor and manage deployments

- **ArgoCD UI:**  
  Forward the UI (if needed) and open [http://localhost:8080](http://localhost:8080):
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
- **ArgoCD CLI:**  
  ```bash
  argocd app list
  argocd app sync <app-name>
  ```
- **All changes to this repo are automatically reconciled and deployed by ArgoCD.**

---

## Ingress Access

After deployment, access your app via:

```bash
http://blackjack-app.ddns.net
```
> _Update your DDNS (e.g., No-IP) to point to the external IP of the ingress controller:_
```bash
kubectl get svc -n ingress-nginx
```
Check the `EXTERNAL-IP` field.

---

## GitOps Automation

- **GitOps automation is handled by your Application repository’s GitHub Actions workflow.**
- When a new Docker image is built and pushed to ECR, your CI pipeline automatically clones this GitOps repository, updates the image tag in `blackjack-stack/values.yaml`, commits, and pushes to the main branch.

- Once committed, **ArgoCD will detect the change and automatically sync the new image to your EKS cluster.**

---

## Versions

| Component       | Chart Version | App Version | Source                 |
|-----------------|--------------|-------------|------------------------|
| `blackjack`     | 1.0.0        | custom      | Local Helm subchart    |
| `mongodb`       | 16.5.24      | 8.0.10      | Bitnami Helm chart     |
| `ingress-nginx` | 4.12.3       | 1.12.3      | Installed via Helm     |
| `elasticsearch` | 22.0.13      | various     | Bitnami Helm chart     |
| `fluent-bit`    | 3.1.8        | various     | Bitnami Helm chart     |
| `kibana`        | 12.1.5       | various     | Bitnami Helm chart     |
| `kube-prometheus-stack` | 75.12.0 | various  | Bitnami Helm chart     |

_Confirm versions with:_  
```bash
cat blackjack-stack/Chart.lock
cat efk-stack/Chart.lock
cat monitor-stack/Chart.lock
helm list -A
```

---

## Cleanup & Redeploy

To completely remove and reinstall the stack(s):

```bash
# Delete the ArgoCD parent Application and all managed resources:
kubectl delete -f apps/app-of-apps.yaml -n argocd
```

To redeploy, just re-apply the App of Apps manifest.

---

## Contact

Alex Machulsky  
[LinkedIn](https://www.linkedin.com/in/alex-machulsky-/)  
[GitHub](https://github.com/alexmachulsky)

---
