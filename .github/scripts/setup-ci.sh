#!/bin/bash

# CI/CD Setup Script
# This script helps configure GitHub Actions and Vercel deployment

set -e

echo "🚀 CI/CD Setup Script"
echo "===================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}Vercel CLI not found. Installing...${NC}"
    npm install -g vercel
    echo -e "${GREEN}✓ Vercel CLI installed${NC}"
else
    echo -e "${GREEN}✓ Vercel CLI already installed${NC}"
fi

# Check if user is logged in to Vercel
echo ""
echo "Checking Vercel authentication..."
if ! vercel whoami &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Vercel. Please log in:${NC}"
    vercel login
else
    echo -e "${GREEN}✓ Logged in to Vercel as $(vercel whoami)${NC}"
fi

# Link project to Vercel
echo ""
echo "Linking project to Vercel..."
if [ ! -d ".vercel" ]; then
    echo -e "${YELLOW}Project not linked. Running vercel link...${NC}"
    vercel link
    echo -e "${GREEN}✓ Project linked to Vercel${NC}"
else
    echo -e "${GREEN}✓ Project already linked to Vercel${NC}"
fi

# Extract Vercel project details
if [ -f ".vercel/project.json" ]; then
    echo ""
    echo "📋 Vercel Project Details:"
    echo "=========================="
    
    VERCEL_ORG_ID=$(cat .vercel/project.json | grep -o '"orgId": "[^"]*' | cut -d'"' -f4)
    VERCEL_PROJECT_ID=$(cat .vercel/project.json | grep -o '"projectId": "[^"]*' | cut -d'"' -f4)
    
    echo "VERCEL_ORG_ID: $VERCEL_ORG_ID"
    echo "VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
    echo ""
    echo -e "${YELLOW}⚠️  Add these as secrets in GitHub:${NC}"
    echo "   1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
    echo "   2. Click 'New repository secret'"
    echo "   3. Add VERCEL_ORG_ID with value: $VERCEL_ORG_ID"
    echo "   4. Add VERCEL_PROJECT_ID with value: $VERCEL_PROJECT_ID"
fi

# Prompt for Vercel token
echo ""
echo "🔑 Vercel Token Setup"
echo "===================="
echo "You need to create a Vercel token for GitHub Actions:"
echo "   1. Go to: https://vercel.com/account/tokens"
echo "   2. Click 'Create Token'"
echo "   3. Name it 'GitHub Actions'"
echo "   4. Copy the token"
echo "   5. Add it as VERCEL_TOKEN secret in GitHub"
echo ""

# Check for .env.local
echo "📝 Environment Variables"
echo "======================="
if [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}⚠️  .env.local not found${NC}"
    echo "Creating .env.local from .env.example..."
    cp .env.example .env.local
    echo -e "${GREEN}✓ Created .env.local${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env.local and add your Supabase credentials${NC}"
else
    echo -e "${GREEN}✓ .env.local exists${NC}"
fi

# Check Supabase configuration
echo ""
echo "🗄️  Supabase Configuration"
echo "========================="
if grep -q "your-project-url-here" .env.local 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Supabase credentials not configured in .env.local${NC}"
    echo "Please update .env.local with your Supabase credentials:"
    echo "   1. Go to: https://app.supabase.com/project/_/settings/api"
    echo "   2. Copy your Project URL and anon key"
    echo "   3. Update .env.local"
else
    echo -e "${GREEN}✓ Supabase credentials configured${NC}"
fi

# Summary
echo ""
echo "📋 Setup Summary"
echo "==============="
echo ""
echo "✅ Completed:"
echo "   - Vercel CLI installed"
echo "   - Project linked to Vercel"
echo "   - .env.local created"
echo ""
echo "⚠️  Manual Steps Required:"
echo ""
echo "1. Add GitHub Secrets:"
echo "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo "   Add the following secrets:"
echo "   - VERCEL_TOKEN (from https://vercel.com/account/tokens)"
echo "   - VERCEL_ORG_ID: $VERCEL_ORG_ID"
echo "   - VERCEL_PROJECT_ID: $VERCEL_PROJECT_ID"
echo "   - NEXT_PUBLIC_SUPABASE_URL (from Supabase Dashboard)"
echo "   - NEXT_PUBLIC_SUPABASE_ANON_KEY (from Supabase Dashboard)"
echo ""
echo "2. Configure Vercel Environment Variables:"
echo "   Go to: https://vercel.com/dashboard"
echo "   Navigate to your project → Settings → Environment Variables"
echo "   Add:"
echo "   - NEXT_PUBLIC_SUPABASE_URL"
echo "   - NEXT_PUBLIC_SUPABASE_ANON_KEY"
echo ""
echo "3. Set up Branch Protection (optional but recommended):"
echo "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/branches"
echo "   Add rule for 'main' branch"
echo "   Enable: Require status checks to pass before merging"
echo ""
echo "4. Test the CI/CD pipeline:"
echo "   - Create a new branch: git checkout -b test-ci"
echo "   - Make a small change and commit"
echo "   - Push: git push origin test-ci"
echo "   - Create a pull request"
echo "   - Watch GitHub Actions run"
echo ""
echo -e "${GREEN}✓ Setup script completed!${NC}"
echo ""
echo "For more information, see:"
echo "   - .github/README.md (CI/CD documentation)"
echo "   - DEPLOYMENT.md (Deployment guide)"
