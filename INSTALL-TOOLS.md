# Install eksctl and kubectl on Windows (Git Bash)

## Step 1: Install eksctl

Open Git Bash and run these commands:

```bash
# Download eksctl
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Windows_amd64.zip"

# Extract
unzip eksctl_Windows_amd64.zip -d eksctl_tmp

# Move to a directory in PATH
mkdir -p ~/bin
mv eksctl_tmp/eksctl.exe ~/bin/

# Add to PATH (add this to ~/.bashrc to make permanent)
export PATH=$PATH:~/bin

# Verify installation
eksctl version
```

**If eksctl command not found after above:**
```bash
# Add to ~/.bashrc permanently
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
source ~/.bashrc
eksctl version
```

## Step 2: Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/amd64/kubectl.exe"

# Move to bin directory
mv kubectl.exe ~/bin/

# Verify installation
kubectl version --client
```

## Step 3: Verify Both Tools

```bash
# Check eksctl
eksctl version

# Check kubectl
kubectl version --client

# Check AWS CLI (you should already have this)
aws --version
```

## Alternative: Using Chocolatey (PowerShell)

If you prefer PowerShell with Chocolatey:

```powershell
# Install eksctl
choco install eksctl

# Install kubectl
choco install kubernetes-cli

# Verify
eksctl version
kubectl version --client
```

## Quick Test

```bash
# Test eksctl
eksctl help

# Test kubectl
kubectl help

# Test AWS CLI
aws sts get-caller-identity
```

## Troubleshooting

### Issue: Command not found

**Fix:**
```bash
# Check if files exist
ls ~/bin/

# Add to PATH
export PATH=$PATH:~/bin

# Make permanent
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Permission denied

**Fix:**
```bash
chmod +x ~/bin/eksctl.exe
chmod +x ~/bin/kubectl.exe
```

### Issue: Can't download

**Fix:** Download manually:
- eksctl: https://github.com/weaveworks/eksctl/releases
- kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

Then move to `~/bin/` directory.

## What's Next?

Once installed, you can create your EKS cluster:

```bash
eksctl create cluster \
  --name nodejs-eks-cluster \
  --region eu-north-1 \
  --nodegroup-name nodejs-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --managed
```

This takes 15-20 minutes and creates everything in AWS!
