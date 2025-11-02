<!--
TEMPLATE INSTRUCTIONS:
Replace these placeholders:
- {{STAGING_ENV}}: Staging environment name (e.g., "staging", "dev")
- {{PROD_ENV}}: Production environment name (e.g., "production", "prod")
- {{BUILD_COMMAND}}: Build command (e.g., "npm run build", "make build")
- {{DEPLOY_TOOL}}: Deployment tool (e.g., "vercel", "heroku", "kubectl")

After customization, remove this comment block.
-->

Deploy the application to staging or production environments.

## Usage

- "Deploy to staging" → deploys to {{STAGING_ENV}}
- "Deploy to production" → deploys to {{PROD_ENV}}

## Pre-deployment Checks

Before deploying, verify:

1. **Tests pass**: Run the test suite
   ```bash
   npm test  # or appropriate test command
   ```

2. **Build succeeds**: Ensure the build completes without errors
   ```bash
   {{BUILD_COMMAND}}
   ```

3. **No uncommitted changes**: Check git status
   ```bash
   git status
   ```

4. **Branch is up-to-date**: Pull latest changes
   ```bash
   git pull origin main
   ```

## Deployment Steps

### Staging Deployment

1. Checkout appropriate branch (usually `develop` or `main`)
2. Run pre-deployment checks above
3. Deploy to {{STAGING_ENV}}:
   ```bash
   {{DEPLOY_TOOL}} deploy --env={{STAGING_ENV}}
   ```
4. Verify deployment:
   - Check health endpoint
   - Test critical functionality
   - Review logs for errors

### Production Deployment

**⚠️ Production deployments require extra caution**

1. Ensure staging deployment is verified and stable
2. Checkout `main` branch
3. Tag the release:
   ```bash
   git tag -a v$(date +%Y%m%d-%H%M) -m "Release $(date +%Y-%m-%d)"
   git push --tags
   ```
4. Run all pre-deployment checks
5. Deploy to {{PROD_ENV}}:
   ```bash
   {{DEPLOY_TOOL}} deploy --env={{PROD_ENV}}
   ```
6. Monitor deployment:
   - Watch logs in real-time
   - Check error rates
   - Verify critical user flows
7. If issues occur, be prepared to rollback:
   ```bash
   {{DEPLOY_TOOL}} rollback --env={{PROD_ENV}}
   ```

## Post-Deployment

After successful deployment:

1. **Smoke test**: Verify core functionality works
2. **Check metrics**: Monitor error rates, response times, resource usage
3. **Update documentation**: Note any changes in deployment process
4. **Notify team**: Announce deployment in team channel

## Rollback Procedure

If deployment fails or causes issues:

```bash
# Quick rollback
{{DEPLOY_TOOL}} rollback --env={{STAGING_ENV|PROD_ENV}}

# Or deploy previous tag
git checkout <previous-tag>
{{DEPLOY_TOOL}} deploy --env={{STAGING_ENV|PROD_ENV}}
```

## Environment-Specific Notes

### {{STAGING_ENV}}
- URL: [Add staging URL]
- Database: [Add staging database info]
- Special considerations: [Add any staging-specific notes]

### {{PROD_ENV}}
- URL: [Add production URL]
- Database: [Add production database info]
- Special considerations: [Add any production-specific notes]

## Troubleshooting

Common deployment issues:

- **Build fails**: Check for dependency conflicts or compilation errors
- **Tests fail**: Fix failing tests before deploying
- **Deployment hangs**: Check network connectivity and service health
- **502/503 errors**: Service may be starting up, wait 30-60 seconds

## Resources

- [Add link to deployment documentation]
- [Add link to environment variables documentation]
- [Add link to monitoring dashboard]
