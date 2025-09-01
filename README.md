# Kamal Test Rails Application

A Rails application deployed to AWS using Kamal and Terraform, with PostgreSQL database and GoodJob for background processing.

## Prerequisites

- Ruby 3.x
- Docker
- Terraform
- Kamal 2.x
- AWS CLI configured
- GitHub account with Container Registry access

## Environment Setup

1. Edit `.envrc` and add your credentials:

- `CLOUDFLARE_API_TOKEN` - For DNS management
- `GHCR_PAT` - GitHub Personal Access Token for Container Registry
- `PRODUCTION_POSTGRES_PASSWORD` - Strong password for PostgreSQL
- `PRODUCTION_POSTGRES_USER` - PostgreSQL username

## Deployment Instructions

### 1. Deploy AWS Infrastructure

First, create the AWS EC2 server and networking infrastructure:

```bash
cd infra
terraform init
terraform plan
terraform apply
cd ..
```

This will create:

- EC2 instance (t3.medium)
- Security groups with proper ports
- SSH key configuration
- Cloudflare DNS records

### 2. Generate Kamal Configuration

After Terraform completes, generate the Kamal deployment configuration from Terraform outputs:

```bash
bin/generate-deploy-config
```

This automatically:

- Fetches the server IP from Terraform state
- Gets the application URL
- Generates `config/deploy.yml` from the template

### 3. Deploy Application with Kamal

For first-time deployment:

```bash
kamal setup
kamal deploy
```

For subsequent deployments:

```bash
kamal deploy
```

## Architecture

- **Web Server**: Rails application served via Kamal proxy with SSL
- **Database**: PostgreSQL 17 running as Kamal accessory
- **Background Jobs**: GoodJob running on separate container
- **Logging**: Papertrail integration for centralized logs
- **Storage**: Persistent volumes for database and Rails storage

## Useful Commands

### Kamal Commands

- `kamal app details` - Check deployment status
- `kamal logs` - View application logs
- `kamal logs -r job` - View job server logs
- `kamal console` - Rails console
- `kamal dbc` - Database console
- `kamal rollback` - Roll back to previous version

### Infrastructure

- SSH to server: `ssh -p 54022 admin@<server-ip>`
- View Terraform outputs: `cd infra && terraform output`
- Destroy infrastructure: `cd infra && terraform destroy`

## Monitoring

- **Application URL**: <https://kamal-test.6temes.net>
- **Logs**: Available via Papertrail (configure endpoint in `config/deploy.yml`)
- **Server**: Monitor via AWS Console or CloudWatch

## Security Notes

- Never commit `.envrc` to version control
- Rotate credentials regularly
- Rails master key is stored in `config/master.key` (gitignored)
- PostgreSQL runs on localhost only, accessible via SSH tunnel
