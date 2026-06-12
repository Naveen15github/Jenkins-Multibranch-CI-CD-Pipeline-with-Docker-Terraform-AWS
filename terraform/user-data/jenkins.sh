#!/bin/bash
set -e

# Update system
yum update -y

# Install Java 11 (required for Jenkins)
amazon-linux-extras install java-openjdk11 -y

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y

# Install Docker
yum install docker -y
systemctl start docker
systemctl enable docker

# Add jenkins user to docker group
usermod -aG docker jenkins
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Git
yum install git -y

# Install Node.js 18 (for running tests in Jenkins)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install nodejs -y

# Install additional utilities
yum install -y wget curl unzip jq

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Configure Jenkins home directory permissions
mkdir -p /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins

# Start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Start SonarQube using Docker
docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:10-community

# Install CloudWatch Logs agent
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch Logs for Jenkins
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name": "/aws/ec2/jenkins-cicd-pipeline-jenkins",
            "log_stream_name": "{instance_id}/jenkins.log"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# Create a marker file to indicate setup is complete
touch /var/lib/jenkins/setup-complete

# Display initial admin password location
echo "=========================================="
echo "Jenkins installation complete!"
echo "Initial admin password location:"
echo "/var/lib/jenkins/secrets/initialAdminPassword"
echo "=========================================="
echo "To retrieve the password, SSH into the instance and run:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "=========================================="
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "SonarQube URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo "=========================================="
