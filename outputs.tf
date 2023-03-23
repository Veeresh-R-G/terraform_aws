output "dev_ip" {
  value       = aws_instance.dev_node.public_ip
  sensitive   = true
  description = "The public IP of the EC2 Instance"
  depends_on  = []
}
