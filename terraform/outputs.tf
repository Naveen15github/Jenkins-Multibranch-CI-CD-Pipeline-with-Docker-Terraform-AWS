# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# Jenkins Server Outputs
output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Jenkins server public IP (Elastic IP)"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins server private IP"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube UI URL"
  value       = "http://${aws_eip.jenkins.public_ip}:9000"
}

# Staging Server Outputs
output "staging_instance_id" {
  description = "Staging EC2 instance ID"
  value       = aws_instance.staging.id
}

output "staging_public_ip" {
  description = "Staging server public IP (Elastic IP)"
  value       = aws_eip.staging.public_ip
}

output "staging_private_ip" {
  description = "Staging server private IP"
  value       = aws_instance.staging.private_ip
}

output "staging_app_url" {
  description = "Staging application URL"
  value       = "http://${aws_eip.staging.public_ip}:3000"
}

# Production Server Outputs
output "production_instance_id" {
  description = "Production EC2 instance ID"
  value       = aws_instance.production.id
}

output "production_public_ip" {
  description = "Production server public IP (Elastic IP)"
  value       = aws_eip.production.public_ip
}

output "production_private_ip" {
  description = "Production server private IP"
  value       = aws_instance.production.private_ip
}

output "production_app_url" {
  description = "Production application URL"
  value       = "http://${aws_eip.production.public_ip}:3000"
}

# Security Group Outputs
output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins.id
}

output "staging_security_group_id" {
  description = "Staging security group ID"
  value       = aws_security_group.staging.id
}

output "production_security_group_id" {
  description = "Production security group ID"
  value       = aws_security_group.production.id
}

# SSH Key Output
output "key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.main.key_name
}

# Connection Information
output "ssh_connection_jenkins" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i <your-private-key.pem> ec2-user@${aws_eip.jenkins.public_ip}"
}

output "ssh_connection_staging" {
  description = "SSH command to connect to Staging server"
  value       = "ssh -i <your-private-key.pem> ec2-user@${aws_eip.staging.public_ip}"
}

output "ssh_connection_production" {
  description = "SSH command to connect to Production server"
  value       = "ssh -i <your-private-key.pem> ec2-user@${aws_eip.production.public_ip}"
}

# Jenkins Initial Password Location
output "jenkins_initial_password_command" {
  description = "Command to retrieve Jenkins initial admin password"
  value       = "ssh -i <your-private-key.pem> ec2-user@${aws_eip.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

# Summary Output
output "deployment_summary" {
  description = "Quick reference for all important URLs and IPs"
  value = {
    jenkins = {
      ui_url       = "http://${aws_eip.jenkins.public_ip}:8080"
      sonarqube_url = "http://${aws_eip.jenkins.public_ip}:9000"
      public_ip    = aws_eip.jenkins.public_ip
      ssh_command  = "ssh -i <your-key.pem> ec2-user@${aws_eip.jenkins.public_ip}"
    }
    staging = {
      app_url     = "http://${aws_eip.staging.public_ip}:3000"
      public_ip   = aws_eip.staging.public_ip
      ssh_command = "ssh -i <your-key.pem> ec2-user@${aws_eip.staging.public_ip}"
    }
    production = {
      app_url     = "http://${aws_eip.production.public_ip}:3000"
      public_ip   = aws_eip.production.public_ip
      ssh_command = "ssh -i <your-key.pem> ec2-user@${aws_eip.production.public_ip}"
    }
  }
}
