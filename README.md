# Node.js CI/CD with Jenkins, Docker, ECR & EKS

Production-ready CI/CD pipeline deploying Node.js applications to AWS EKS (Kubernetes) using Jenkins.

## 🚀 What's Different from ECS?

**ECS (Previous Project):**
- AWS-specific container orchestration
- Simpler, managed service
- Good for straightforward deployments

**EKS (This Project):**
- Full Kubernetes (K8s) platform
- Industry-standard orchestration
- More features: ConfigMaps, Secrets, StatefulSets, DaemonSets
- Better for complex microservices
- Multi-cloud portable

## 📋 Architecture

```
GitHub → Jenkins (EC2) → Docker Build → ECR → 
EKS Cluster → Kubernetes Deployment → Service → ALB
```

**Components:**
- Jenkins CI/CD server on EC2
- Docker containerization
- Amazon ECR for image registry
- EKS cluster with managed node groups
- Kubernetes deployments and services
- AWS Load Balancer Controller
- CloudWatch for logging

## ⚡ Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
cd nodejs-jenkins-eks-demo

# Configure AWS
aws configure

# Deploy infrastructure (20-25 minutes)
chmod +x scripts/deploy-all.sh
./scripts/deploy-all.sh

# Access application
kubectl get svc nodejs-app-service
```

## 📁 Project Structure

```
nodejs-jenkins-eks-demo/
├── app/                          # Node.js application
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # K8s deployment
│   ├── service.yaml              # K8s service (LoadBalancer)
│   └── configmap.yaml            # Configuration
├── jenkins/
│   └── Jenkinsfile               # CI/CD pipeline
├── infra/                        # CloudFormation templates
│   ├── 01-vpc.yml                # VPC for EKS
│   ├── 02-eks-cluster.yml        # EKS control plane
│   ├── 03-eks-nodegroup.yml      # Worker nodes
│   ├── 04-jenkins.yml            # Jenkins server
│   └── 05-ecr.yml                # ECR repository
└── scripts/
    ├── deploy-all.sh             # Deploy everything
    ├── setup-kubectl.sh          # Configure kubectl
    └── cleanup.sh                # Remove all resources
```

## 🎯 Features

- ✅ Full Kubernetes orchestration
- ✅ Auto-scaling (HPA & Cluster Autoscaler)
- ✅ Rolling updates with health checks
- ✅ ConfigMaps and Secrets management
- ✅ Service discovery
- ✅ Ingress/LoadBalancer support
- ✅ Persistent volumes
- ✅ Namespace isolation

## 💰 Cost Estimate

Running 24/7 in eu-north-1:
- EKS Control Plane: ~$73/month
- EC2 Worker Nodes (2x t3.medium): ~$60/month
- Jenkins EC2 (t3.medium): ~$30/month
- ALB: ~$20/month
- ECR + Data transfer: ~$6/month
- **Total: ~$189/month**

Note: EKS is more expensive than ECS due to control plane costs

## 📚 Documentation

- **[Quick Start](QUICKSTART.md)** - Get started quickly
- **[Deployment Guide](DEPLOYMENT-GUIDE.md)** - Complete setup
- **[Kubernetes Guide](K8S-GUIDE.md)** - K8s concepts
- **[Architecture](ARCHITECTURE.md)** - System design

## 🔧 Technology Stack

- **Application**: Node.js 18, Express
- **CI/CD**: Jenkins
- **Containerization**: Docker
- **Registry**: Amazon ECR
- **Orchestration**: Kubernetes (EKS)
- **Infrastructure**: AWS CloudFormation
- **CLI Tools**: kubectl, eksctl

## Account Details

- **Account ID**: 047861165149
- **Region**: eu-north-1
