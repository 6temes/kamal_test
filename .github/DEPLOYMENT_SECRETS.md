# GitHub Secrets Required for Deployment

The following secrets must be configured in your GitHub repository settings (Settings → Secrets and variables → Actions) for the automated deployment to work:

## Required Secrets

1. **GITHUB_ACTIONS_DEPLOY_KEY**
   - The private SSH key for GitHub Actions deployment
   - Already generated and saved at: `~/.ssh/github_actions_deploy`
   - Copy the contents: `cat ~/.ssh/github_actions_deploy`
   - The corresponding public key is already in `infra/terraform.tfvars`

2. **SERVER_IP**
   - The IP address of your deployment server
   - Can be obtained from Terraform output: `cd infra && terraform output server_ip`

3. **GHCR_PAT**
   - GitHub Personal Access Token with `write:packages` permission
   - Create at: https://github.com/settings/tokens
   - Used to push/pull images from GitHub Container Registry

4. **RAILS_MASTER_KEY**
   - The Rails master key from `config/master.key`
   - Never commit this file to the repository

5. **POSTGRES_USER**
   - PostgreSQL database username
   - Must match the value in your `.envrc`

6. **POSTGRES_PASSWORD**
   - PostgreSQL database password
   - Should be a strong, secure password


## Setting Secrets via GitHub CLI

You can set these secrets using the GitHub CLI:

```bash
# Install GitHub CLI if not already installed
# brew install gh

# Authenticate
gh auth login

# Set secrets (replace with your actual values)
gh secret set GITHUB_ACTIONS_DEPLOY_KEY < ~/.ssh/github_actions_deploy
gh secret set SERVER_IP --body "YOUR_SERVER_IP"
gh secret set GHCR_PAT --body "YOUR_GITHUB_PAT"
gh secret set RAILS_MASTER_KEY < config/master.key
gh secret set POSTGRES_USER --body "YOUR_POSTGRES_USER"
gh secret set POSTGRES_PASSWORD --body "YOUR_POSTGRES_PASSWORD"
```

## Verifying the Setup

After setting up the secrets:

1. Push a commit to the `main` branch
2. Check the Actions tab in your GitHub repository
3. The CI workflow should run first
4. If CI passes, the Deploy workflow will automatically trigger
5. Monitor the deployment logs for any issues

## Troubleshooting

- If deployment fails with SSH errors, verify the GITHUB_ACTIONS_DEPLOY_KEY is correct
- If registry authentication fails, ensure GHCR_PAT has the correct permissions
- Check that SERVER_IP is correct and the server is accessible
- Verify all environment variables match between local `.envrc` and GitHub secrets