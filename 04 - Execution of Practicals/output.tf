output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_server.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.my_server.private_ip
}

output "total_servers" {
  description = "Total number of servers"
  value       = length(var.server_names)
}

output "development_instance_type" {
  value = var.instance_types["dev"]
}

output "production_instance_type" {
  value = var.instance_types["prod"]
}
