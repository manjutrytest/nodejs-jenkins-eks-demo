#!/bin/bash

REGION="eu-north-1"
ENV_NAME="nodejs-eks"

echo "🗑️  Cleaning up EKS resources..."

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/ || true

# Delete stacks in reverse order
echo "Deleting Jenkins..."
aws cloudformation delete-stack --stack-name ${ENV_NAME}-jenkins --region ${REGION}

echo "Deleting Node Group..."
aws cloudformation delete-stack --stack-name ${ENV_NAME}-nodegroup --region ${REGION}
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-nodegroup --region ${REGION}

echo "Deleting EKS Cluster..."
aws cloudformation delete-stack --stack-name ${ENV_NAME}-cluster --region ${REGION}
aws cloudformation wait stack-delete-complete --stack-name ${ENV_NAME}-cluster --region ${REGION}

echo "Deleting ECR..."
aws cloudformation delete-stack --stack-name ${ENV_NAME}-ecr --region ${REGION}

echo "Deleting VPC..."
aws cloudformation delete-stack --stack-name ${ENV_NAME}-vpc --region ${REGION}

echo "✅ Cleanup complete!"
