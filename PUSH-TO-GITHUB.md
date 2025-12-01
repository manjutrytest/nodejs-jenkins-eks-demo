# 🚀 Push to GitHub - Step by Step

## Important: Run These Commands in Git Bash

Open **Git Bash** and navigate to the project directory:

```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo
```

---

## Step 1: Initialize Git in Project Directory

```bash
# Remove any existing git config (if needed)
rm -rf .git

# Initialize fresh git repository
git init

# Set default branch to main
git branch -M main
```

---

## Step 2: Add All Project Files

```bash
# Add all files
git add .

# Check what will be committed
git status
```

You should see all your project files ready to commit.

---

## Step 3: Commit the Files

```bash
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"
```

---

## Step 4: Create GitHub Repository

1. Open browser: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Description: `CI/CD Pipeline for Node.js on AWS EKS with Jenkins`
4. Select: **Public** (or Private)
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**

---

## Step 5: Add Remote and Push

**Replace YOUR_USERNAME with your actual GitHub username:**

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Verify remote
git remote -v

# Push to GitHub
git push -u origin main
```

---

## If You Get Authentication Error

GitHub requires a Personal Access Token (PAT) instead of password.

### Generate Token:
1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Note: `Jenkins EKS Demo`
4. Expiration: `90 days` (or your preference)
5. Select scopes:
   - ✅ **repo** (all)
6. Click **"Generate token"**
7. **Copy the token** (you won't see it again!)

### Push with Token:
```bash
git push -u origin main
```

When prompted:
- Username: `YOUR_GITHUB_USERNAME`
- Password: `PASTE_YOUR_TOKEN_HERE`

---

## Verify Success

After pushing, you should see:

```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
Delta compression using up to 8 threads
Compressing objects: 100% (38/38), done.
Writing objects: 100% (45/45), 25.43 KiB | 2.54 MiB/s, done.
Total 45 (delta 5), reused 0 (delta 0), pack-reused 0
To https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

✅ **Success!** Go to your GitHub repository to see your code.

---

## Quick Commands Summary

```bash
# Navigate to project
cd /c/Users/mangowra/nodejs-jenkins-eks-demo

# Initialize git
git init
git branch -M main

# Add and commit
git add .
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push
git push -u origin main
```

---

## Next Steps

After successfully pushing to GitHub:

1. ✅ **Configure kubectl on Jenkins** (see GIT-PUSH-AND-WEBHOOK-SETUP.md - Step 2)
2. ✅ **Setup GitHub Webhook** (see GIT-PUSH-AND-WEBHOOK-SETUP.md - Step 3)
3. ✅ **Create Jenkins Pipeline** (see GIT-PUSH-AND-WEBHOOK-SETUP.md - Step 4)

---

## Troubleshooting

### Issue: "fatal: not a git repository"
**Solution:** Make sure you're in the correct directory
```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo
pwd  # Should show the project directory
```

### Issue: "remote origin already exists"
**Solution:** Remove and re-add
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
```

### Issue: Authentication failed
**Solution:** Use Personal Access Token instead of password (see above)

### Issue: "Updates were rejected"
**Solution:** Force push (only for initial setup)
```bash
git push -u origin main --force
```

---

**Once pushed, open GIT-PUSH-AND-WEBHOOK-SETUP.md for the complete guide!** 🚀
