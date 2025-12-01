#!/bin/bash
# Script to configure kubectl on Jenkins EC2 instance

echo "=== Configuring kubectl for Jenkins user ==="

# Switch to jenkins user and configure kubectl
sudo su - jenkins << 'EOF'
echo "Configuring kubectl for EKS cluster..."
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

echo "Testing kubectl connection..."
kubectl get nodes

echo "Checking cluster info..."
kubectl cluster-info

echo "Listing all pods..."
kubectl get pods -A

echo "✅ kubectl configuration complete!"
EOF

echo ""
echo "=== Configuration Summary ==="
echo "Jenkins user can now access EKS cluster: nodejs-eks-cluster"
echo "Region: eu-north-1"
echo ""
