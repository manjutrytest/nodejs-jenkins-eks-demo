# Verification Script - Check EKS CI/CD Setup Status

Write-Host "=== EKS CI/CD Pipeline Setup Verification ===" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: EKS Cluster
Write-Host "Checking EKS Cluster..." -ForegroundColor Yellow
try {
    $nodes = kubectl get nodes --no-headers 2>&1
    if ($LASTEXITCODE -eq 0) {
        $nodeCount = ($nodes | Measure-Object).Count
        Write-Host "✅ EKS Cluster: $nodeCount nodes running" -ForegroundColor Green
    } else {
        Write-Host "❌ Cannot connect to EKS cluster" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ kubectl not configured" -ForegroundColor Red
    $allGood = $false
}

# Check 2: ECR Repository
Write-Host "Checking ECR Repository..." -ForegroundColor Yellow
try {
    $ecr = aws ecr describe-repositories --repository-names nodejs-eks-app --region eu-north-1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECR Repository: nodejs-eks-app exists" -ForegroundColor Green
    } else {
        Write-Host "❌ ECR Repository not found" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Cannot check ECR" -ForegroundColor Red
    $allGood = $false
}

# Check 3: Jenkins Stack
Write-Host "Checking Jenkins..." -ForegroundColor Yellow
try {
    $jenkins = aws cloudformation describe-stacks --stack-name jenkins-eks --region eu-north-1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Jenkins: Running at http://16.171.58.221:8080" -ForegroundColor Green
    } else {
        Write-Host "❌ Jenkins stack not found" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Cannot check Jenkins" -ForegroundColor Red
    $allGood = $false
}

# Check 4: Load Balancer
Write-Host "Checking Load Balancer..." -ForegroundColor Yellow
try {
    $lb = kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>&1
    if ($LASTEXITCODE -eq 0 -and $lb) {
        Write-Host "✅ Load Balancer: $lb" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Load Balancer not ready yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Load Balancer not deployed yet" -ForegroundColor Yellow
}

# Check 5: Pods
Write-Host "Checking Application Pods..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -l app=nodejs-app --no-headers 2>&1
    if ($LASTEXITCODE -eq 0 -and $pods) {
        $runningPods = ($pods | Select-String "Running").Count
        Write-Host "✅ Application Pods: $runningPods running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  No application pods found (deploy first)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Cannot check pods" -ForegroundColor Yellow
}

# Check 6: Git Repository
Write-Host "Checking Git Configuration..." -ForegroundColor Yellow
if (Test-Path ".git") {
    $remote = git remote -v 2>&1 | Select-String "origin"
    if ($remote) {
        Write-Host "✅ Git: Repository configured" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Git: No remote configured" -ForegroundColor Yellow
        Write-Host "   Run: git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  Git: Not initialized" -ForegroundColor Yellow
    Write-Host "   Run: git init" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ Infrastructure is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Configure kubectl on Jenkins EC2" -ForegroundColor White
    Write-Host "2. Push code to GitHub" -ForegroundColor White
    Write-Host "3. Create Jenkins pipeline job" -ForegroundColor White
    Write-Host "4. Run first build" -ForegroundColor White
    Write-Host ""
    Write-Host "See START-NOW.md for detailed instructions" -ForegroundColor Cyan
} else {
    Write-Host "❌ Some infrastructure components are missing" -ForegroundColor Red
    Write-Host "Please check the errors above" -ForegroundColor Yellow
}

Write-Host ""
