output "server_ip" {
  description = "Public IP address of the server"
  value       = aws_instance.app_server.public_ip
}

output "server_name" {
  description = "Name of the server"
  value       = aws_instance.app_server.tags.Name
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "ssh_connection_string" {
  description = "SSH connection string for the admin user"
  value       = "ssh -p ${var.ssh_port} admin@${aws_instance.app_server.public_ip}"
}

output "app_url" {
  description = "Application URL"
  value       = "https://${var.app_subdomain}.${var.domain_name}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://grafana.${var.app_subdomain}.${var.domain_name}"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://prometheus.${var.app_subdomain}.${var.domain_name}"
}


