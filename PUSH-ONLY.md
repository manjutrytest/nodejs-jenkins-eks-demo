# 🚀 Push nodejs-jenkins-eks-demo to GitHub

## Simple 5-Step Process

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Description: `CI/CD Pipeline for Node.js on AWS EKS with Jenkins`
4. Select: **Public**
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**
7. **Keep the page open** - you'll need the URL

---

### Step 2: Open Git Bash in Project Folder

**Option A:** Right-click method
1. Open File Explorer
2. Navigate to: `C:\Users\mangowra\nodejs-jenkins-eks-demo`
3. Right-click in the folder (not on a file)
4. Select **"Git Bash Here"**

**Option B:** Command method
1. Open Git Bash
2. Run: `cd /c/Users/mangowra/nodejs-jenkins-eks-demo`

---

### Step 3: Initialize Git

In Git Bash, run these commands:

```bash
# Remove any existing git config
rm -rf .git

# Initialize fresh git repository
git init

# Set default branch to main
git branch -M main
```

---

### Step 4: Add and Commit Files

```bash
# Add all files in the project
git add .

# Check what will be committed (optional)
git status

# Commit the files
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"
```

---

### Step 5: Push to GitHub

**Replace YOUR_USERNAME with your actual GitHub username:**

```bash
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push to GitHub
git push -u origin main
```

---

## Authentication

When prompted for credentials:

**Username:** Your GitHub username

**Password:** Use a **Personal Access Token** (NOT your GitHub password)

### How to Get Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Note: `Jenkins EKS Demo`
4. Expiration: `90 days`
5. Select scopes: ✅ **repo** (check all repo boxes)
6. Click **"Generate token"**
7. **COPY THE TOKEN** (you won't see it again!)
8. Use this token as your password when pushing

---

## Verify Success

After pushing, you should see output like:

```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
Delta compression using up to 8 threads
Compressing objects: 100% (38/38), done.
Writing objects: 100% (45/45), 25.43 KiB | 2.54 MiB/s, done.
Total 45 (delta 5), reused 0 (delta 0)
To https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

✅ **Success!** 

Go to: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo`

You should see all your files!

---

## All Commands in One Block

Copy and paste these (replace YOUR_USERNAME):

```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo
rm -rf .git
git init
git branch -M main
git add .
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git push -u origin main
```

---

## Troubleshooting

### Issue: "fatal: not a git repository"
**Solution:** Make sure you're in the correct directory
```bash
pwd  # Should show: /c/Users/mangowra/nodejs-jenkins-eks-demo
```

### Issue: "remote origin already exists"
**Solution:**
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
```

### Issue: Authentication failed
**Solution:** Use Personal Access Token (see above)

### Issue: "Updates were rejected"
**Solution:** Force push (only for initial setup)
```bash
git push -u origin main --force
```

---

## Next Steps

After successfully pushing to GitHub:

1. ✅ Configure kubectl on Jenkins EC2
2. ✅ Setup GitHub webhook
3. ✅ Create Jenkins pipeline

See **COMPLETE-SETUP-GUIDE.md** for the remaining steps.

---

**That's it! Just 5 simple steps to push your code to GitHub.** 🚀
