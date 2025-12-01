# Script to push code to GitHub

Write-Host "=== Push Code to GitHub ===" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# Add all files
Write-Host "Adding files..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "EKS CI/CD pipeline setup"

# Check if remote exists
$remoteExists = git remote | Select-String "origin"

if (-not $remoteExists) {
    Write-Host ""
    Write-Host "No remote repository configured." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create a GitHub repository and run:" -ForegroundColor Yellow
    Write-Host "git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git" -ForegroundColor Green
    Write-Host "git push -u origin main" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push
    Write-Host ""
    Write-Host "✅ Code pushed successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next: Create Jenkins pipeline job" -ForegroundColor Cyan
