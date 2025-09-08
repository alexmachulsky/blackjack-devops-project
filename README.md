# Blackjack Game on AWS

A simple project that deploys a blackjack card game to Amazon Web Services using modern DevOps tools.

## What This Is

This project takes a Python blackjack game and automatically deploys it to the cloud using:
- **AWS EKS** - Amazon's managed Kubernetes service
- **Terraform** - Creates all AWS infrastructure automatically
- **ArgoCD** - Handles app deployments and updates

## What You Get

When you run this project, you'll have:
- A working blackjack game running in the cloud
- Monitoring dashboards to see how it's performing
- Automatic deployments when you make code changes

## How to Use It

### Prerequisites
- AWS account
- AWS CLI installed and configured
- Terraform installed
- kubectl installed

### Deploy Everything

1. **Create the infrastructure:**
   ```bash
   cd infrastructure/TerraformEKS_withEBS-CSI-StorageClass
   terraform init
   terraform apply
   ```

2. **Connect to your cluster:**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name blackjack-eks-cluster
   ```

3. **Verify it's working:**
   ```bash
   kubectl get nodes
   ```

That's it! ArgoCD will automatically deploy the blackjack game.

## Play the Game

Once deployed, you can access your blackjack game at the load balancer URL that AWS creates.

## View Monitoring

See how your app is performing:
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Then visit http://localhost:3000

## Test Locally First

Want to try the game on your computer before deploying?
```bash
cd app/
python app.py
```
Visit http://localhost:5000

## Important: Cleanup

This creates real AWS resources that cost money (~$50-80 per month).

**When you're done, destroy everything:**
```bash
cd infrastructure/TerraformEKS_withEBS-CSI-StorageClass
terraform destroy
```

## What This Project Demonstrates

- How to deploy applications to AWS using Infrastructure as Code
- Kubernetes container orchestration
- GitOps deployment practices
- Cloud monitoring and observability

Perfect for learning DevOps concepts or showing technical skills to employers.

## License

MIT License - see the LICENSE file.

## 📊 Monitoring

Access monitoring dashboards:

```bash
# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Kibana
kubectl port-forward -n logging svc/kibana 5601:5601

# ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:80
```

## 🛠️ Development

### Local Development

```bash
cd app/
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

### Building Container Image

```bash
cd app/
docker build -t blackjack-app .
docker run -p 5000:5000 blackjack-app
```

## 🔄 GitOps Workflow

1. **Code Changes**: Push changes to GitHub repository
2. **CI Pipeline**: GitHub Actions builds and pushes container images
3. **Image Update**: ArgoCD detects new image versions
4. **Deployment**: ArgoCD automatically deploys updates to EKS
5. **Monitoring**: Prometheus alerts on deployment status

## 📈 Scaling

The application supports horizontal scaling:

```bash
kubectl scale deployment blackjack-app --replicas=5
```

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
2. **Pod CrashLoopBackOff**: Check logs with `kubectl logs <pod-name>`
3. **ArgoCD Sync Issues**: Verify GitHub repository access
4. **Secret Sync Failures**: Check External Secrets Operator logs

### Getting Help

- Check the logs: `kubectl logs -n <namespace> <pod-name>`
- Describe resources: `kubectl describe <resource-type> <resource-name>`
- Monitor events: `kubectl get events --sort-by='.metadata.creationTimestamp'`

## 🧹 Cleanup & Cost Management

**⚠️ Important:** To avoid ongoing AWS charges, destroy the infrastructure when not needed:

```bash
cd infrastructure/TerraformEKS_withEBS-CSI-StorageClass
terraform destroy
```

**Manual Cleanup (if needed):**
- Delete any remaining Load Balancers in AWS Console
- Check for orphaned EBS volumes
- Verify VPC resources are removed

## 📊 Demo & Screenshots

### Application Interface
Access the blackjack game at: `http://<load-balancer-dns>/`

### Monitoring Dashboards
- **Grafana**: `kubectl port-forward -n monitoring svc/grafana 3000:80`
- **Kibana**: `kubectl port-forward -n logging svc/kibana 5601:5601`
- **ArgoCD**: `kubectl port-forward -n argocd svc/argocd-server 8080:80`

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
