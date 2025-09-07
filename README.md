# Blackjack DevOps Project

A complete end-to-end DevOps project demonstrating modern cloud-native application deployment using AWS EKS, Terraform, ArgoCD, and GitOps practices.

## �� Project Overview

This project showcases a full-stack blackjack game application deployed on AWS EKS using infrastructure as code, GitOps, and modern DevOps practices. It includes:

- **Application**: Python Flask blackjack game
- **Infrastructure**: AWS EKS cluster provisioned with Terraform
- **Deployment**: Kubernetes manifests and Helm charts
- **GitOps**: ArgoCD for continuous deployment
- **Monitoring**: Prometheus, Grafana, and ELK stack
- **Secret Management**: AWS Secrets Manager with External Secrets Operator

## 📁 Repository Structure

```
├── app/                    # Application source code
│   ├── app.py             # Flask application
│   ├── Dockerfile         # Container image definition
│   └── requirements.txt   # Python dependencies
│
├── infrastructure/        # Terraform infrastructure code
│   └── TerraformEKS_withEBS-CSI-StorageClass/
│       ├── MAIN.tf        # EKS cluster configuration
│       ├── argocd.tf      # ArgoCD installation
│       ├── external-secrets.tf  # AWS Secrets Manager integration
│       └── modules/       # Terraform modules
│
└── kubernetes/           # Kubernetes manifests and Helm charts
    ├── blackjack-stack/  # Main application Helm chart
    ├── monitor-stack/    # Monitoring stack (Prometheus/Grafana)
    ├── efk-stack/        # Logging stack (Elasticsearch/Fluentd/Kibana)
    └── apps/             # ArgoCD application definitions
```

## 🏗️ Architecture

### Infrastructure Components
- **AWS EKS**: Managed Kubernetes cluster
- **VPC**: Custom networking with public/private subnets
- **EBS CSI**: Persistent storage for stateful workloads
- **Application Load Balancer**: Ingress traffic routing
- **IAM Roles**: Fine-grained permissions with OIDC

### Application Stack
- **Frontend**: Python Flask web application
- **Database**: MongoDB replica set with persistent storage
- **Ingress**: NGINX Ingress Controller
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)

### DevOps Tools
- **GitOps**: ArgoCD for continuous deployment
- **Secret Management**: AWS Secrets Manager + External Secrets Operator
- **Infrastructure as Code**: Terraform
- **Container Registry**: AWS ECR
- **CI/CD**: GitHub Actions

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- Helm >= 3.0
- Docker

### 1. Deploy Infrastructure

\`\`\`bash
cd infrastructure/TerraformEKS_withEBS-CSI-StorageClass
terraform init
terraform plan
terraform apply
\`\`\`

### 2. Configure kubectl

\`\`\`bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
\`\`\`

### 3. Deploy Applications

The applications will be automatically deployed via ArgoCD once the infrastructure is ready.

## 🔧 Key Features

### Secret Management
- **AWS Secrets Manager**: Centralized secret storage
- **External Secrets Operator**: Kubernetes-native secret synchronization
- **Encrypted at rest**: All secrets encrypted in AWS

### High Availability
- **MongoDB Replica Set**: Database redundancy
- **Multi-AZ Deployment**: Cross-availability zone distribution
- **Auto-scaling**: Horizontal Pod Autoscaler configured

### Monitoring & Observability
- **Metrics**: Prometheus scraping application and infrastructure metrics
- **Dashboards**: Grafana dashboards for visualization
- **Logs**: Centralized logging with ELK stack
- **Alerts**: Configurable alerting rules

### Security
- **Network Policies**: Pod-to-pod communication restrictions
- **RBAC**: Role-based access control
- **Security Groups**: AWS-level network security
- **Image Scanning**: Container vulnerability assessment

## 📊 Monitoring

Access monitoring dashboards:

\`\`\`bash
# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Kibana
kubectl port-forward -n logging svc/kibana 5601:5601

# ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:80
\`\`\`

## 🛠️ Development

### Local Development

\`\`\`bash
cd app/
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
\`\`\`

### Building Container Image

\`\`\`bash
cd app/
docker build -t blackjack-app .
docker run -p 5000:5000 blackjack-app
\`\`\`

## 🔄 GitOps Workflow

1. **Code Changes**: Push changes to GitHub repository
2. **CI Pipeline**: GitHub Actions builds and pushes container images
3. **Image Update**: ArgoCD detects new image versions
4. **Deployment**: ArgoCD automatically deploys updates to EKS
5. **Monitoring**: Prometheus alerts on deployment status

## 📈 Scaling

The application supports horizontal scaling:

\`\`\`bash
kubectl scale deployment blackjack-app --replicas=5
\`\`\`

MongoDB replica set provides database scaling and high availability.

## 🔒 Security Considerations

- All secrets stored in AWS Secrets Manager
- Network traffic encrypted in transit
- Container images scanned for vulnerabilities
- RBAC policies enforce least privilege access
- Regular security updates via automated pipelines

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues

1. **EKS Access Denied**: Ensure AWS credentials have proper EKS permissions
2. **Pod CrashLoopBackOff**: Check logs with \`kubectl logs <pod-name>\`
3. **ArgoCD Sync Issues**: Verify GitHub repository access
4. **Secret Sync Failures**: Check External Secrets Operator logs

### Getting Help

- Check the logs: \`kubectl logs -n <namespace> <pod-name>\`
- Describe resources: \`kubectl describe <resource-type> <resource-name>\`
- Monitor events: \`kubectl get events --sort-by='.metadata.creationTimestamp'\`

## 🏆 Project Highlights

This project demonstrates:
- **Infrastructure as Code** with Terraform
- **GitOps** practices with ArgoCD
- **Cloud-native** application architecture
- **Modern secret management** with AWS integration
- **Comprehensive monitoring** and observability
- **Security best practices** throughout the stack
- **Scalable and resilient** design patterns

---

Built with ❤️ for learning and demonstrating modern DevOps practices.
