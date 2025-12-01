# Node.js EKS CI/CD Pipeline with Jenkins

Production-ready CI/CD pipeline for deploying Node.js applications to Amazon EKS using Jenkins, Docker, and ECR.

## 🎯 Overview

This repository contains a complete, automated CI/CD pipeline that:
- Builds Docker images on every code push
- Pushes images to Amazon ECR
- Deploys to Amazon EKS with zero downtime
- Uses Jenkins for automation
- Includes all infrastructure as code

## 🏗️ Architecture

```
GitHub → Jenkins → Docker → ECR → EKS → Load Balancer
```

**Components:**
- **Application**: Node.js Express API
- **Container Registry**: Amazon ECR
- **Orchestration**: Amazon EKS (Kubernetes)
- **CI/CD**: Jenkins on EC2
- **Infrastructure**: AWS CloudFormation

## 📁 Project Structure

```
nodejs-jenkins-eks-demo/
├── app/                          # Node.js application
│   ├── server.js                 # Express server
│   ├── package.json              # Dependencies
│   └── Dockerfile                # Container image
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # App deployment (3 replicas)
│   ├── service.yaml              # Load balancer service
│   └── configmap.yaml            # Configuration
├── jenkins/                      # CI/CD pipeline
│   └── Jenkinsfile               # Pipeline definition
├── infra/                        # CloudFormation templates
│   ├── 01-vpc.yml                # VPC and networking
│   ├── 02-eks-cluster.yml        # EKS cluster
│   ├── 03-eks-nodegroup.yml      # Worker nodes
│   ├── 04-ecr.yml                # Container registry
│   └── 05-jenkins-standalone.yml # Jenkins server
├── scripts/                      # Deployment scripts
│   └── deploy-all.ps1            # One-command deployment
├── DEPLOYMENT-GUIDE.md           # Complete setup guide
├── ARCHITECTURE.md               # Architecture details
└── COMMANDS-CHEATSHEET.md        # Quick reference
```

## 🚀 Quick Start for Your Team

### Prerequisites

- AWS CLI configured with credentials
- kubectl installed
- eksctl installed
- Git installed
- AWS account with appropriate permissions

### Clone and Deploy

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
cd nodejs-jenkins-eks-demo

# Deploy infrastructure (PowerShell)
.\scripts\deploy-all.ps1

# Or deploy manually (see DEPLOYMENT-GUIDE.md)
```

### Complete Setup (30 minutes)

1. **Deploy Infrastructure** - Run deployment script
2. **Configure Jenkins** - Access Jenkins UI and install plugins
3. **Setup GitHub Webhook** - Enable automatic builds
4. **Create Pipeline** - Configure Jenkins pipeline job
5. **Deploy Application** - First build and deployment

**See `DEPLOYMENT-GUIDE.md` for detailed step-by-step instructions.**

## ✨ Features

- ✅ **Automated CI/CD** - Push code, auto-deploy
- ✅ **Zero Downtime** - Rolling updates
- ✅ **Scalable** - Kubernetes orchestration
- ✅ **Production Ready** - Health checks, monitoring
- ✅ **Infrastructure as Code** - CloudFormation templates
- ✅ **Load Balanced** - AWS ELB integration

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **DEPLOYMENT-GUIDE.md** | Complete deployment instructions |
| **ARCHITECTURE.md** | System architecture and design |
| **COMMANDS-CHEATSHEET.md** | Quick command reference |

## 🔧 Configuration

### Update for Your Environment

1. **AWS Account ID** - Update in `jenkins/Jenkinsfile`:
   ```groovy
   AWS_ACCOUNT_ID = 'YOUR_ACCOUNT_ID'
   ```

2. **Region** - Update in all CloudFormation templates and Jenkinsfile:
   ```yaml
   AWS_REGION = 'your-region'
   ```

3. **Application Name** - Update in `app/server.js` if needed

## 🧪 Testing

After deployment, test your application:

```powershell
# Get Load Balancer URL
kubectl get svc nodejs-app-service

# Test endpoint
curl http://YOUR-LOAD-BALANCER-URL
```

**Expected response:**
```json
{
  "message": "Node.js App on EKS - Jenkins CI/CD by manju",
  "version": "1.0.0",
  "timestamp": "2025-12-01T09:21:04.489Z",
  "environment": "production",
  "pod": "nodejs-app-xxxxx"
}
```

## 🔄 CI/CD Workflow

1. Developer pushes code to GitHub
2. GitHub webhook triggers Jenkins
3. Jenkins builds Docker image
4. Image pushed to Amazon ECR
5. Jenkins deploys to EKS
6. Kubernetes performs rolling update
7. Application live with zero downtime

**Total time: ~5 minutes from push to production**

## 📊 Monitoring

```powershell
# View pods
kubectl get pods

# View logs
kubectl logs -f deployment/nodejs-app

# View service
kubectl get svc nodejs-app-service

# Describe deployment
kubectl describe deployment nodejs-app
```

## 🛠️ Useful Commands

```powershell
# Scale application
kubectl scale deployment nodejs-app --replicas=5

# Rollback deployment
kubectl rollout undo deployment/nodejs-app

# Restart deployment
kubectl rollout restart deployment/nodejs-app

# View rollout status
kubectl rollout status deployment/nodejs-app
```

## 🆘 Troubleshooting

### Build Fails
- Check Jenkins console output
- Verify AWS credentials
- Check ECR repository exists

### Deployment Fails
- Verify kubectl is configured: `kubectl get nodes`
- Check pod status: `kubectl get pods`
- View pod logs: `kubectl logs POD_NAME`

### Application Not Accessible
- Wait 2-3 minutes for DNS propagation
- Check service: `kubectl get svc`
- Verify Load Balancer is active in AWS Console

**See DEPLOYMENT-GUIDE.md for detailed troubleshooting.**

## 🧹 Cleanup

To delete all resources:

```powershell
# Delete EKS cluster
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1

# Delete CloudFormation stacks
aws cloudformation delete-stack --stack-name jenkins-eks --region eu-north-1
aws cloudformation delete-stack --stack-name eks-ecr --region eu-north-1
aws cloudformation delete-stack --stack-name eks-nodegroup --region eu-north-1
aws cloudformation delete-stack --stack-name eks-cluster --region eu-north-1
aws cloudformation delete-stack --stack-name eks-vpc --region eu-north-1
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is provided as-is for educational and demonstration purposes.

## 👥 Team Usage

This repository is designed to be cloned and deployed by your team:

1. **Clone** the repository
2. **Update** AWS account ID and region in configuration files
3. **Deploy** using the provided scripts
4. **Customize** the application as needed
5. **Push** changes to trigger automatic deployments

**Your team can have this running in under 30 minutes!**

---

**Built with ❤️ for production-grade Kubernetes deployments**
