#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-eks"

echo "🚀 Deploying EKS infrastructure..."

# Deploy VPC
echo "📦 Deploying VPC..."
aws cloudformation deploy \
  --template-file infra/01-vpc.yml \
  --stack-name ${ENV_NAME}-vpc \
  --region ${REGION}

# Deploy ECR
echo "📦 Deploying ECR..."
aws cloudformation deploy \
  --template-file infra/04-ecr.yml \
  --stack-name ${ENV_NAME}-ecr \
  --region ${REGION}

# Deploy EKS Cluster
echo "🎯 Deploying EKS Cluster (this takes 10-15 minutes)..."
aws cloudformation deploy \
  --template-file infra/02-eks-cluster.yml \
  --stack-name ${ENV_NAME}-cluster \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${REGION}

# Deploy Node Group
echo "🖥️  Deploying Node Group (this takes 5-10 minutes)..."
aws cloudformation deploy \
  --template-file infra/03-eks-nodegroup.yml \
  --stack-name ${ENV_NAME}-nodegroup \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${REGION}

# Deploy Jenkins
echo "🔧 Deploying Jenkins..."
aws cloudformation deploy \
  --template-file infra/05-jenkins.yml \
  --stack-name ${ENV_NAME}-jenkins \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ${REGION}

# Get Jenkins IP
JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name ${ENV_NAME}-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' \
  --output text \
  --region ${REGION})

echo ""
echo "✅ Infrastructure deployed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure kubectl:"
echo "   aws eks update-kubeconfig --name ${ENV_NAME}-cluster --region ${REGION}"
echo ""
echo "2. Verify cluster:"
echo "   kubectl get nodes"
echo ""
echo "3. Access Jenkins at: http://${JENKINS_IP}:8080"
echo "4. Get Jenkins password:"
echo "   ssh ec2-user@${JENKINS_IP} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
echo ""
echo "5. Build and push initial image in Jenkins"
echo "6. Deploy to Kubernetes:"
echo "   kubectl apply -f k8s/"
