terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  # Uses CLOUDFLARE_API_TOKEN environment variable
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the latest Debian 12 AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian official

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a key pair for SSH access
resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

# Security group for the application server
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.project_name}-sg"
  description = "Security group for Kamal application server"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-security-group"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "kamal-app"
  }
}

# EC2 instance for the application server
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.debian.id
  instance_type         = var.instance_type
  key_name              = aws_key_pair.app_key.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id             = data.aws_subnets.default.ids[0]

  user_data = file("${path.module}/cloud-init.yml")

  # Enable detailed monitoring
  monitoring = var.enable_detailed_monitoring

  # Root block device configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
    tags = {
      Name        = "${var.project_name}-root-volume"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = var.server_name
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "kamal-app"
  }

  lifecycle {
    create_before_destroy = true
  }

  # Wait for instance to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init completed!'",
      "echo 'Verifying Docker installation...'",
      "sudo docker --version",
      "echo 'Verifying SSH port configuration...'",
      "sudo ss -tlnp | grep :${var.ssh_port}",
      "echo 'Server initialization complete!'"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      port        = var.ssh_port
      timeout     = "10m"
      
      # Retry connection until SSH is available on custom port
      agent = false
    }
  }
}

# Null resource to check server readiness after apply
resource "null_resource" "server_ready_check" {
  depends_on = [aws_instance.app_server]

  triggers = {
    instance_id = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "🔄 Waiting for server to be fully initialized..."
      sleep 10
      max_attempts=30
      attempt=1
      
      while [ $attempt -le $max_attempts ]; do
        if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p ${var.ssh_port} admin@${aws_instance.app_server.public_ip} "docker --version" >/dev/null 2>&1; then
          echo "✅ Server is ready!"
          echo "   - Public IP: ${aws_instance.app_server.public_ip}"
          echo "   - SSH Port: ${var.ssh_port}"
          echo "   - Docker is installed and running"
          exit 0
        fi
        
        echo "⏳ Attempt $attempt/$max_attempts: Server not ready yet, waiting..."
        sleep 10
        attempt=$((attempt + 1))
      done
      
      echo "❌ Server failed to become ready after $max_attempts attempts"
      exit 1
    EOT
  }
}

# Note: Using instance public IP directly instead of Elastic IP due to permissions

# Cloudflare DNS Configuration
data "cloudflare_zone" "domain" {
  name = var.domain_name
}

resource "cloudflare_record" "app_a" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.app_subdomain
  type    = "A"
  content = aws_instance.app_server.public_ip
  ttl     = 1 # Auto TTL when proxied
  proxied = true
}

resource "cloudflare_record" "grafana_a" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "grafana.${var.app_subdomain}"
  type    = "A"
  content = aws_instance.app_server.public_ip
  ttl     = 300 # 5 minutes for DNS only
  proxied = false # DNS only (gray cloud) for Let's Encrypt
}

resource "cloudflare_record" "prometheus_a" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "prometheus.${var.app_subdomain}"
  type    = "A"
  content = aws_instance.app_server.public_ip
  ttl     = 300 # 5 minutes for DNS only
  proxied = false # DNS only (gray cloud) for Let's Encrypt
}

