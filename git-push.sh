#!/bin/bash
# Git Push Script for Git Bash
# Run this in Git Bash from the nodejs-jenkins-eks-demo directory

echo "=== Git Push to GitHub ==="
echo ""

# Check if we're in the right directory
if [ ! -f "jenkins/Jenkinsfile" ]; then
    echo "❌ Error: Not in the correct directory!"
    echo "Please run: cd /c/Users/mangowra/nodejs-jenkins-eks-demo"
    exit 1
fi

echo "✅ In correct directory"
echo ""

# Remove existing .git if it exists
if [ -d ".git" ]; then
    echo "Removing existing .git directory..."
    rm -rf .git
fi

# Initialize git
echo "Initializing git repository..."
git init
git branch -M main

# Add all files
echo "Adding files..."
git add .

# Show status
echo ""
echo "Files to be committed:"
git status --short

# Commit
echo ""
echo "Committing files..."
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"

# Prompt for GitHub username
echo ""
echo "Enter your GitHub username:"
read GITHUB_USERNAME

# Add remote
echo ""
echo "Adding remote repository..."
git remote add origin https://github.com/$GITHUB_USERNAME/nodejs-jenkins-eks-demo.git

# Show remote
echo ""
echo "Remote repository:"
git remote -v

# Push
echo ""
echo "Pushing to GitHub..."
echo "You may be prompted for your GitHub username and Personal Access Token"
echo ""
git push -u origin main

# Check if push was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "Repository URL: https://github.com/$GITHUB_USERNAME/nodejs-jenkins-eks-demo"
    echo ""
    echo "Next steps:"
    echo "1. Configure kubectl on Jenkins EC2"
    echo "2. Setup GitHub webhook"
    echo "3. Create Jenkins pipeline"
    echo ""
    echo "See GIT-PUSH-AND-WEBHOOK-SETUP.md for details"
else
    echo ""
    echo "❌ Push failed!"
    echo ""
    echo "If authentication failed:"
    echo "1. Generate Personal Access Token at: https://github.com/settings/tokens"
    echo "2. Use token as password when prompted"
    echo ""
    echo "Then try again: git push -u origin main"
fi
