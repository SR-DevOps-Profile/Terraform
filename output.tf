output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.test.id
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.test.private_ip
}

output "instance_public_ip" {
  description = "The Elastic IP of the EC2 instance"
  value       = aws_eip.my_eip.public_ip
}
