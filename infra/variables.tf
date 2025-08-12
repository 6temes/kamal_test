variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "kamal-app-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file for provisioning"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 54022
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming and labeling"
  type        = string
  default     = "kamal-app"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (additional cost applies)"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "domain_name" {
  description = "The root domain name in Cloudflare"
  type        = string
  default     = "6temes.net"
}

variable "app_subdomain" {
  description = "Subdomain for the application"
  type        = string
  default     = "kamal-test"
}