# CI/CD Setup Script for Windows
# This script helps configure GitHub Actions and Vercel deployment

Write-Host "🚀 CI/CD Setup Script" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""

# Check if Vercel CLI is installed
Write-Host "Checking for Vercel CLI..." -ForegroundColor Yellow
try {
    $vercelVersion = vercel --version 2>$null
    Write-Host "✓ Vercel CLI already installed (version: $vercelVersion)" -ForegroundColor Green
} catch {
    Write-Host "Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g vercel
    Write-Host "✓ Vercel CLI installed" -ForegroundColor Green
}

# Check if user is logged in to Vercel
Write-Host ""
Write-Host "Checking Vercel authentication..." -ForegroundColor Yellow
try {
    $vercelUser = vercel whoami 2>$null
    Write-Host "✓ Logged in to Vercel as $vercelUser" -ForegroundColor Green
} catch {
    Write-Host "Not logged in to Vercel. Please log in:" -ForegroundColor Yellow
    vercel login
}

# Link project to Vercel
Write-Host ""
Write-Host "Linking project to Vercel..." -ForegroundColor Yellow
if (-not (Test-Path ".vercel")) {
    Write-Host "Project not linked. Running vercel link..." -ForegroundColor Yellow
    vercel link
    Write-Host "✓ Project linked to Vercel" -ForegroundColor Green
} else {
    Write-Host "✓ Project already linked to Vercel" -ForegroundColor Green
}

# Extract Vercel project details
if (Test-Path ".vercel/project.json") {
    Write-Host ""
    Write-Host "📋 Vercel Project Details:" -ForegroundColor Cyan
    Write-Host "==========================" -ForegroundColor Cyan
    
    $projectJson = Get-Content ".vercel/project.json" | ConvertFrom-Json
    $VERCEL_ORG_ID = $projectJson.orgId
    $VERCEL_PROJECT_ID = $projectJson.projectId
    
    Write-Host "VERCEL_ORG_ID: $VERCEL_ORG_ID"
    Write-Host "VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
    Write-Host ""
    Write-Host "⚠️  Add these as secrets in GitHub:" -ForegroundColor Yellow
    Write-Host "   1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
    Write-Host "   2. Click 'New repository secret'"
    Write-Host "   3. Add VERCEL_ORG_ID with value: $VERCEL_ORG_ID"
    Write-Host "   4. Add VERCEL_PROJECT_ID with value: $VERCEL_PROJECT_ID"
}

# Prompt for Vercel token
Write-Host ""
Write-Host "🔑 Vercel Token Setup" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host "You need to create a Vercel token for GitHub Actions:"
Write-Host "   1. Go to: https://vercel.com/account/tokens"
Write-Host "   2. Click 'Create Token'"
Write-Host "   3. Name it 'GitHub Actions'"
Write-Host "   4. Copy the token"
Write-Host "   5. Add it as VERCEL_TOKEN secret in GitHub"
Write-Host ""

# Check for .env.local
Write-Host "📝 Environment Variables" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
if (-not (Test-Path ".env.local")) {
    Write-Host "⚠️  .env.local not found" -ForegroundColor Yellow
    Write-Host "Creating .env.local from .env.example..."
    Copy-Item ".env.example" ".env.local"
    Write-Host "✓ Created .env.local" -ForegroundColor Green
    Write-Host "⚠️  Please edit .env.local and add your Supabase credentials" -ForegroundColor Yellow
} else {
    Write-Host "✓ .env.local exists" -ForegroundColor Green
}

# Check Supabase configuration
Write-Host ""
Write-Host "🗄️  Supabase Configuration" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
$envContent = Get-Content ".env.local" -Raw
if ($envContent -match "your-project-url-here") {
    Write-Host "⚠️  Supabase credentials not configured in .env.local" -ForegroundColor Yellow
    Write-Host "Please update .env.local with your Supabase credentials:"
    Write-Host "   1. Go to: https://app.supabase.com/project/_/settings/api"
    Write-Host "   2. Copy your Project URL and anon key"
    Write-Host "   3. Update .env.local"
} else {
    Write-Host "✓ Supabase credentials configured" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "📋 Setup Summary" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Completed:" -ForegroundColor Green
Write-Host "   - Vercel CLI installed"
Write-Host "   - Project linked to Vercel"
Write-Host "   - .env.local created"
Write-Host ""
Write-Host "⚠️  Manual Steps Required:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Add GitHub Secrets:"
Write-Host "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
Write-Host "   Add the following secrets:"
Write-Host "   - VERCEL_TOKEN (from https://vercel.com/account/tokens)"
Write-Host "   - VERCEL_ORG_ID: $VERCEL_ORG_ID"
Write-Host "   - VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
Write-Host "   - NEXT_PUBLIC_SUPABASE_URL (from Supabase Dashboard)"
Write-Host "   - NEXT_PUBLIC_SUPABASE_ANON_KEY (from Supabase Dashboard)"
Write-Host ""
Write-Host "2. Configure Vercel Environment Variables:"
Write-Host "   Go to: https://vercel.com/dashboard"
Write-Host "   Navigate to your project → Settings → Environment Variables"
Write-Host "   Add:"
Write-Host "   - NEXT_PUBLIC_SUPABASE_URL"
Write-Host "   - NEXT_PUBLIC_SUPABASE_ANON_KEY"
Write-Host ""
Write-Host "3. Set up Branch Protection (optional but recommended):"
Write-Host "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/branches"
Write-Host "   Add rule for 'main' branch"
Write-Host "   Enable: Require status checks to pass before merging"
Write-Host ""
Write-Host "4. Test the CI/CD pipeline:"
Write-Host "   - Create a new branch: git checkout -b test-ci"
Write-Host "   - Make a small change and commit"
Write-Host "   - Push: git push origin test-ci"
Write-Host "   - Create a pull request"
Write-Host "   - Watch GitHub Actions run"
Write-Host ""
Write-Host "✓ Setup script completed!" -ForegroundColor Green
Write-Host ""
Write-Host "For more information, see:"
Write-Host "   - .github/README.md (CI/CD documentation)"
Write-Host "   - DEPLOYMENT.md (Deployment guide)"
