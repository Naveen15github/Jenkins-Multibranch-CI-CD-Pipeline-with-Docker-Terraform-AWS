# General Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "jenkins-cicd-pipeline"
}

# Network Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Security Variables
variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to instances"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Change this to your IP for production!
}

variable "allowed_jenkins_cidr" {
  description = "CIDR blocks allowed to access Jenkins UI and SonarQube"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Change this to your IP for production!
}

# SSH Key Variable
variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  # You must provide this value in terraform.tfvars or via CLI
  # Example: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...
}

# EC2 Instance Types
variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t3.medium" # 2 vCPU, 4 GB RAM
}

variable "staging_instance_type" {
  description = "EC2 instance type for Staging server"
  type        = string
  default     = "t3.micro" # 2 vCPU, 1 GB RAM
}

variable "production_instance_type" {
  description = "EC2 instance type for Production server"
  type        = string
  default     = "t3.small" # 2 vCPU, 2 GB RAM
}

# Docker Hub Credentials
variable "docker_hub_username" {
  description = "Docker Hub username for pulling images"
  type        = string
  default     = ""
}

variable "docker_hub_password" {
  description = "Docker Hub password or token"
  type        = string
  sensitive   = true
  default     = ""
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
