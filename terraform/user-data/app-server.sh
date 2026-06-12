#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
yum install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install additional utilities
yum install -y wget curl unzip jq git

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install CloudWatch Logs agent
yum install -y amazon-cloudwatch-agent

# Get instance ID and determine environment based on tags
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
ENVIRONMENT=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Environment" --region $REGION --query 'Tags[0].Value' --output text 2>/dev/null || echo "unknown")

# Configure CloudWatch Logs
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/docker-app.log",
            "log_group_name": "/aws/ec2/jenkins-cicd-pipeline-$ENVIRONMENT",
            "log_stream_name": "{instance_id}/docker-app.log"
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

# Create log file for Docker application logs
touch /var/log/docker-app.log
chmod 666 /var/log/docker-app.log

# Create a systemd service to stream Docker logs to file
cat > /etc/systemd/system/docker-log-streamer.service <<EOF
[Unit]
Description=Docker Log Streamer
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'docker logs -f cicd-app >> /var/log/docker-app.log 2>&1 || true'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable the service (will start once container is running)
systemctl daemon-reload
systemctl enable docker-log-streamer.service

# Create a marker file to indicate setup is complete
touch /home/ec2-user/setup-complete

echo "=========================================="
echo "Application server setup complete!"
echo "Environment: $ENVIRONMENT"
echo "Instance ready for deployment"
echo "=========================================="
