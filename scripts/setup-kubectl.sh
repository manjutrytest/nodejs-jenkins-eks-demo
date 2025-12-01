#!/bin/bash

REGION="eu-north-1"
CLUSTER_NAME="nodejs-eks-cluster"

echo "🔧 Configuring kubectl for EKS..."

# Update kubeconfig
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}

# Verify connection
echo ""
echo "📊 Cluster Info:"
kubectl cluster-info

echo ""
echo "🖥️  Nodes:"
kubectl get nodes

echo ""
echo "📦 Namespaces:"
kubectl get namespaces

echo ""
echo "✅ kubectl configured successfully!"
echo ""
echo "Try these commands:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"
echo "  kubectl apply -f k8s/"
