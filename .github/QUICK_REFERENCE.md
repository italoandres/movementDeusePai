# CI/CD Quick Reference Guide

Quick commands and procedures for common CI/CD tasks.

## Table of Contents

- [Initial Setup](#initial-setup)
- [Running Tests Locally](#running-tests-locally)
- [Deployment Commands](#deployment-commands)
- [Troubleshooting](#troubleshooting)
- [Common Tasks](#common-tasks)

## Initial Setup

### One-Time Setup

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Login to Vercel
vercel login

# 3. Link project
vercel link

# 4. Run setup script (Linux/Mac)
bash .github/scripts/setup-ci.sh

# Or on Windows (PowerShell)
.\.github\scripts\setup-ci.ps1
```

### Configure GitHub Secrets

Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

Add these secrets:
- `VERCEL_TOKEN` - From https://vercel.com/account/tokens
- `VERCEL_ORG_ID` - From `.vercel/project.json`
- `VERCEL_PROJECT_ID` - From `.vercel/project.json`
- `NEXT_PUBLIC_SUPABASE_URL` - From Supabase Dashboard
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - From Supabase Dashboard

## Running Tests Locally

### Unit Tests

```bash
# Run all tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test -- --coverage
```

### Property-Based Tests

```bash
# Run with default iterations (100)
npm run test

# Run with more iterations
PROPERTY_TEST_RUNS=1000 npm run test
```

### E2E Tests (Playwright)

```bash
# Install Playwright browsers (first time only)
npx playwright install

# Run E2E tests
npx playwright test

# Run E2E tests in UI mode
npx playwright test --ui

# Run specific test file
npx playwright test tests/journey.spec.ts
```

### Lint and Type Check

```bash
# Run ESLint
npm run lint

# Fix ESLint issues automatically
npm run lint -- --fix

# Type check
npx tsc --noEmit
```

## Deployment Commands

### Preview Deployment

```bash
# Deploy to preview environment
vercel

# Deploy with specific environment variables
vercel --env NEXT_PUBLIC_SUPABASE_URL=your-url
```

### Production Deployment

```bash
# Deploy to production
vercel --prod

# Deploy specific branch to production
vercel --prod --branch main
```

### Check Deployment Status

```bash
# List recent deployments
vercel ls

# Get deployment details
vercel inspect <deployment-url>

# View logs
vercel logs <deployment-url>
```

## Troubleshooting

### Tests Failing Locally

```bash
# Clear test cache
npm run test -- --clearCache

# Run tests with verbose output
npm run test -- --verbose

# Run specific test file
npm run test -- path/to/test.test.ts
```

### Build Failing

```bash
# Clear Next.js cache
rm -rf .next

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Try building locally
npm run build
```

### Vercel Deployment Issues

```bash
# Check Vercel status
vercel whoami

# Re-link project
rm -rf .vercel
vercel link

# Pull environment variables
vercel env pull .env.local

# Check deployment logs
vercel logs <deployment-url> --follow
```

### GitHub Actions Failing

1. Check workflow logs in GitHub Actions tab
2. Look for specific error messages
3. Common fixes:
   ```bash
   # Update dependencies
   npm update
   
   # Fix security vulnerabilities
   npm audit fix
   
   # Regenerate lock file
   rm package-lock.json
   npm install
   ```

## Common Tasks

### Create a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes and commit
git add .
git commit -m "feat: add my feature"

# 3. Push to GitHub
git push origin feature/my-feature

# 4. Create pull request on GitHub
# CI will automatically run and create preview deployment

# 5. After approval, merge to main
# Production deployment will automatically run
```

### Rollback a Deployment

#### Via Vercel Dashboard

1. Go to Vercel Dashboard → Your Project → Deployments
2. Find the last good deployment
3. Click "⋯" menu → "Promote to Production"

#### Via Git

```bash
# Find the commit to revert
git log --oneline

# Revert the commit
git revert <commit-hash>

# Push to trigger new deployment
git push origin main
```

### Update Environment Variables

#### In Vercel

1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables
2. Update the variable
3. Redeploy for changes to take effect

#### In GitHub

1. Go to Repository Settings → Secrets and variables → Actions
2. Update the secret
3. Re-run the workflow

### Run CI Checks Before Pushing

```bash
# Run all checks locally
npm run lint && npm run test && npm run build

# Or create a pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
npm run lint && npm run test
EOF

chmod +x .git/hooks/pre-push
```

### View Deployment Logs

```bash
# Real-time logs
vercel logs <deployment-url> --follow

# Last 100 lines
vercel logs <deployment-url> --limit 100

# Filter by function
vercel logs <deployment-url> --function api/progress
```

### Test Preview Deployment

```bash
# Get preview URL from PR comment or:
vercel ls

# Test the preview
curl https://your-preview-url.vercel.app/api/health

# Or open in browser
open https://your-preview-url.vercel.app
```

### Update Workflow Files

```bash
# Edit workflow
vim .github/workflows/ci.yml

# Validate workflow syntax (requires act)
act --list

# Test workflow locally (requires act)
act push
```

### Monitor CI/CD Performance

```bash
# View workflow run times
gh run list --limit 10

# View specific run details
gh run view <run-id>

# Download workflow logs
gh run download <run-id>
```

## Useful Aliases

Add these to your `.bashrc` or `.zshrc`:

```bash
# Testing
alias test='npm run test'
alias test:watch='npm run test:watch'
alias test:e2e='npx playwright test'

# Deployment
alias deploy:preview='vercel'
alias deploy:prod='vercel --prod'
alias deploy:logs='vercel logs'

# CI/CD
alias ci:check='npm run lint && npm run test && npm run build'
alias ci:fix='npm run lint -- --fix'

# Git workflow
alias feature='git checkout -b feature/'
alias push:feature='git push origin $(git branch --show-current)'
```

## Environment-Specific Commands

### Development

```bash
# Start dev server
npm run dev

# Run with specific port
PORT=3001 npm run dev

# Clear cache and start
rm -rf .next && npm run dev
```

### Staging/Preview

```bash
# Deploy to preview
vercel

# Test preview deployment
curl https://your-preview.vercel.app/api/health
```

### Production

```bash
# Deploy to production
vercel --prod

# Check production status
curl https://your-app.vercel.app/api/health

# View production logs
vercel logs your-app.vercel.app --follow
```

## Keyboard Shortcuts

### GitHub Actions

- `?` - Show keyboard shortcuts
- `t` - Open file finder
- `w` - Focus on workflow search
- `l` - Jump to logs

### Vercel Dashboard

- `⌘/Ctrl + K` - Open command palette
- `⌘/Ctrl + P` - Quick project switcher

## Quick Links

- [GitHub Actions Dashboard](https://github.com/YOUR_USERNAME/YOUR_REPO/actions)
- [Vercel Dashboard](https://vercel.com/dashboard)
- [Supabase Dashboard](https://app.supabase.com)
- [Codecov Dashboard](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO)

## Emergency Procedures

### Production is Down

1. **Immediate rollback**:
   ```bash
   # Via Vercel Dashboard: Promote last good deployment
   # Or via CLI:
   vercel rollback
   ```

2. **Check logs**:
   ```bash
   vercel logs your-app.vercel.app --follow
   ```

3. **Verify Supabase**:
   - Check Supabase Dashboard for outages
   - Verify database is accessible

4. **Notify team**:
   - Post in team chat
   - Update status page if applicable

### CI/CD Pipeline Broken

1. **Check GitHub Actions status**: https://www.githubstatus.com
2. **Check Vercel status**: https://www.vercel-status.com
3. **Bypass CI temporarily** (emergency only):
   - Disable branch protection
   - Merge directly
   - Re-enable branch protection

### Secrets Compromised

1. **Rotate immediately**:
   ```bash
   # Generate new Vercel token
   # Update GitHub secret
   # Redeploy
   ```

2. **Check for unauthorized access**:
   - Review Vercel deployment logs
   - Review Supabase auth logs
   - Check for suspicious activity

3. **Update all affected secrets**

---

**Last Updated**: 2025  
**Maintained By**: Development Team
