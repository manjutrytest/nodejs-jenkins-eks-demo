$REGION = "eu-north-1"
$ENV_NAME = "nodejs-eks"

Write-Host "🚀 Deploying EKS infrastructure to AWS..." -ForegroundColor Green
Write-Host "This will take 20-25 minutes" -ForegroundColor Yellow
Write-Host ""

# Deploy VPC
Write-Host "📦 Step 1/5: Deploying VPC..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/01-vpc.yml `
  --stack-name "$ENV_NAME-vpc" `
  --region $REGION

# Deploy ECR
Write-Host "📦 Step 2/5: Deploying ECR..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/04-ecr.yml `
  --stack-name "$ENV_NAME-ecr" `
  --region $REGION

# Deploy EKS Cluster
Write-Host "🎯 Step 3/5: Deploying EKS Cluster (10-15 minutes)..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/02-eks-cluster.yml `
  --stack-name "$ENV_NAME-cluster" `
  --capabilities CAPABILITY_NAMED_IAM `
  --region $REGION

# Deploy Node Group
Write-Host "🖥️  Step 4/5: Deploying Worker Nodes (5-10 minutes)..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/03-eks-nodegroup.yml `
  --stack-name "$ENV_NAME-nodegroup" `
  --capabilities CAPABILITY_NAMED_IAM `
  --region $REGION

# Deploy Jenkins
Write-Host "🔧 Step 5/5: Deploying Jenkins..." -ForegroundColor Cyan
aws cloudformation deploy `
  --template-file infra/05-jenkins.yml `
  --stack-name "$ENV_NAME-jenkins" `
  --capabilities CAPABILITY_NAMED_IAM `
  --region $REGION

# Get Jenkins IP
$JENKINS_IP = aws cloudformation describe-stacks `
  --stack-name "$ENV_NAME-jenkins" `
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' `
  --output text `
  --region $REGION

Write-Host ""
Write-Host "✅ Infrastructure deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Access Jenkins at: http://$JENKINS_IP:8080"
Write-Host ""
Write-Host "2. Get Jenkins password using AWS Systems Manager:"
Write-Host "   - Go to EC2 Console"
Write-Host "   - Select Jenkins instance"
Write-Host "   - Click Connect -> Session Manager"
Write-Host "   - Run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
Write-Host ""
Write-Host "3. Setup Jenkins:"
Write-Host "   - Install suggested plugins"
Write-Host "   - Install: Docker Pipeline, Kubernetes CLI"
Write-Host "   - Create pipeline job pointing to your GitHub repo"
Write-Host ""
Write-Host "4. Build in Jenkins to deploy to EKS"
Write-Host ""
Write-Host "5. Get app URL:"
Write-Host "   - Go to EC2 -> Load Balancers"
Write-Host "   - Find the NLB created by Kubernetes"
Write-Host "   - Copy DNS name"
