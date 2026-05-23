# CI/CD Pipeline Documentation

This directory contains GitHub Actions workflows for continuous integration and deployment.

## Workflows

### 1. CI Pipeline (`ci.yml`)

Runs on every push and pull request to `main` and `develop` branches.

#### Jobs

##### Unit Tests
- Runs all unit tests using Vitest
- Uploads coverage reports to Codecov
- **Triggers**: Push, Pull Request
- **Duration**: ~2-3 minutes

##### Property-Based Tests
- Runs property-based tests with fast-check
- Executes 100+ iterations per property
- **Triggers**: Push, Pull Request
- **Duration**: ~3-5 minutes

##### Integration Tests
- Tests Supabase integration
- Uses PostgreSQL service container
- Tests authentication, RLS policies, and data operations
- **Triggers**: Push, Pull Request
- **Duration**: ~3-4 minutes

##### E2E Tests
- Runs end-to-end tests with Playwright
- Tests critical user journeys
- Uploads test reports as artifacts
- **Triggers**: Push, Pull Request
- **Duration**: ~5-7 minutes

##### Lint & Type Check
- Runs ESLint for code quality
- Runs TypeScript type checking
- **Triggers**: Push, Pull Request
- **Duration**: ~1-2 minutes

##### Build
- Builds the Next.js application
- Uploads build artifacts
- **Triggers**: Push, Pull Request (after unit tests and lint pass)
- **Duration**: ~2-3 minutes

**Total CI Duration**: ~15-20 minutes

### 2. Deployment Pipeline (`deploy.yml`)

Handles deployment to Vercel for preview and production environments.

#### Jobs

##### Deploy Preview
- **Triggers**: Pull Request to `main`
- Deploys to Vercel preview environment
- Comments on PR with preview URL
- Automatically updates on new commits
- **Duration**: ~3-4 minutes

##### Deploy Production
- **Triggers**: Push to `main` branch
- Deploys to Vercel production environment
- Creates deployment summary
- Notifies on success/failure
- **Duration**: ~3-4 minutes

## Required Secrets

Configure these secrets in your GitHub repository settings:

### GitHub Secrets Configuration

Go to **Repository Settings → Secrets and variables → Actions** and add:

#### Vercel Secrets

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `VERCEL_TOKEN` | Vercel authentication token | Vercel Dashboard → Settings → Tokens → Create Token |
| `VERCEL_ORG_ID` | Your Vercel organization ID | Run `vercel link` locally, find in `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | Your Vercel project ID | Run `vercel link` locally, find in `.vercel/project.json` |

#### Supabase Secrets (for testing)

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `SUPABASE_TEST_URL` | Test Supabase project URL | Supabase Dashboard → Test Project → Settings → API |
| `SUPABASE_TEST_ANON_KEY` | Test Supabase anon key | Supabase Dashboard → Test Project → Settings → API |
| `SUPABASE_TEST_SERVICE_ROLE_KEY` | Test Supabase service role key | Supabase Dashboard → Test Project → Settings → API |

#### Production Secrets

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Production Supabase URL | Supabase Dashboard → Production Project → Settings → API |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Production Supabase anon key | Supabase Dashboard → Production Project → Settings → API |

### Setting Up Vercel Secrets

1. **Install Vercel CLI**:
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Link your project**:
   ```bash
   vercel link
   ```
   
   This creates a `.vercel/project.json` file with your `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID`.

4. **Create a Vercel token**:
   - Go to [Vercel Dashboard → Settings → Tokens](https://vercel.com/account/tokens)
   - Click **"Create Token"**
   - Name it "GitHub Actions"
   - Set scope to your organization
   - Copy the token (you won't see it again!)

5. **Add secrets to GitHub**:
   - Go to your GitHub repository
   - Navigate to **Settings → Secrets and variables → Actions**
   - Click **"New repository secret"**
   - Add each secret from the table above

## Workflow Triggers

### Automatic Triggers

| Event | Workflow | Jobs |
|-------|----------|------|
| Push to `main` | CI + Deploy Production | All CI jobs + Production deployment |
| Push to `develop` | CI only | All CI jobs |
| Pull Request to `main` | CI + Deploy Preview | All CI jobs + Preview deployment |
| Pull Request to `develop` | CI only | All CI jobs |

### Manual Triggers

You can manually trigger workflows from the GitHub Actions tab:

1. Go to **Actions** tab in your repository
2. Select the workflow you want to run
3. Click **"Run workflow"**
4. Select the branch
5. Click **"Run workflow"**

## Workflow Status Badges

Add these badges to your main README.md:

```markdown
![CI Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg)
![Deployment](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/deploy.yml/badge.svg)
```

Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub username and repository name.

## Monitoring Workflows

### View Workflow Runs

1. Go to the **Actions** tab in your repository
2. Click on a workflow to see all runs
3. Click on a specific run to see job details
4. Click on a job to see step-by-step logs

### Debugging Failed Workflows

If a workflow fails:

1. **Check the logs**: Click on the failed job to see detailed logs
2. **Check the step**: Identify which step failed
3. **Common issues**:
   - **Tests failing**: Run tests locally to reproduce
   - **Build failing**: Check for missing dependencies or environment variables
   - **Deployment failing**: Verify Vercel secrets are correct
   - **Timeout**: Increase timeout or optimize the step

### Re-running Workflows

To re-run a failed workflow:

1. Go to the failed workflow run
2. Click **"Re-run jobs"** in the top right
3. Select **"Re-run failed jobs"** or **"Re-run all jobs"**

## Best Practices

### Branch Protection Rules

Configure branch protection for `main`:

1. Go to **Settings → Branches**
2. Add rule for `main` branch
3. Enable:
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Select required status checks:
     - `unit-tests`
     - `property-tests`
     - `integration-tests`
     - `e2e-tests`
     - `lint`
     - `build`
   - ✅ Require pull request reviews before merging (1 approval)
   - ✅ Dismiss stale pull request approvals when new commits are pushed

### Pull Request Workflow

1. Create a feature branch from `develop`
2. Make your changes
3. Push to GitHub
4. Create a pull request to `develop`
5. Wait for CI to pass
6. Request review
7. Address feedback
8. Merge to `develop`
9. When ready for production, create PR from `develop` to `main`
10. CI + preview deployment runs
11. Test preview deployment
12. Merge to `main`
13. Production deployment runs automatically

### Environment Strategy

- **Development**: Local development with `.env.local`
- **Preview**: Vercel preview deployments (PR branches)
- **Production**: Vercel production deployment (`main` branch)

Use separate Supabase projects for each environment:
- Development: Local Supabase or shared dev project
- Preview: Separate Supabase test project
- Production: Production Supabase project

## Troubleshooting

### Common Issues

#### "Resource not accessible by integration"

**Cause**: GitHub token doesn't have required permissions

**Solution**: 
1. Go to **Settings → Actions → General**
2. Under "Workflow permissions", select **"Read and write permissions"**
3. Save changes

#### "Vercel token is invalid"

**Cause**: Vercel token is incorrect or expired

**Solution**:
1. Create a new token in Vercel Dashboard
2. Update `VERCEL_TOKEN` secret in GitHub
3. Re-run the workflow

#### "Cannot find module" during build

**Cause**: Dependency not installed or incorrect import

**Solution**:
1. Verify dependency is in `package.json`
2. Run `npm install` locally to test
3. Check import paths are correct
4. Ensure case-sensitive file names match

#### Tests timeout

**Cause**: Tests taking too long or hanging

**Solution**:
1. Increase timeout in workflow file
2. Optimize slow tests
3. Check for infinite loops or missing test cleanup

### Getting Help

If you encounter issues:

1. Check workflow logs for detailed error messages
2. Review [GitHub Actions Documentation](https://docs.github.com/en/actions)
3. Review [Vercel CLI Documentation](https://vercel.com/docs/cli)
4. Open an issue in the repository with:
   - Workflow run URL
   - Error message
   - Steps to reproduce

## Maintenance

### Updating Dependencies

Keep workflow dependencies up to date:

```yaml
# Update action versions regularly
- uses: actions/checkout@v4  # Check for v5
- uses: actions/setup-node@v4  # Check for v5
- uses: actions/upload-artifact@v4  # Check for v5
```

### Monitoring Costs

GitHub Actions provides:
- 2,000 minutes/month for free (public repos)
- 3,000 minutes/month for Pro accounts

Monitor usage:
1. Go to **Settings → Billing → Plans and usage**
2. View **Actions** usage
3. Optimize workflows if approaching limits

Vercel provides:
- Unlimited deployments for Hobby plan
- 100 GB bandwidth/month

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Vercel Deployment Documentation](https://vercel.com/docs/deployments/overview)
- [Next.js CI/CD Guide](https://nextjs.org/docs/deployment#continuous-integration-ci)
- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)

---

**Last Updated**: 2025  
**Maintained By**: Development Team
