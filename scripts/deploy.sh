#!/bin/bash
set -e

echo "========================================="
echo " Deploying to server: ${SERVER_IP}"
echo " Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
echo "========================================="

SSH_OPTS="-o StrictHostKeyChecking=no -i ${SSH_PRIVATE_KEY}"

ssh ${SSH_OPTS} ${DEPLOY_USER}@${SERVER_IP} << ENDSSH
  set -e

  echo "Pulling Docker image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
  docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER}

  echo "Stopping old container if running..."
  docker stop ${CONTAINER_NAME} 2>/dev/null || true
  docker rm ${CONTAINER_NAME} 2>/dev/null || true

  echo "Starting new container..."
  docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${APP_PORT}:3000 \
    -e NODE_ENV=production \
    ${DOCKER_IMAGE}:${BUILD_NUMBER}

  echo "Container started successfully."
  docker ps | grep ${CONTAINER_NAME}
ENDSSH

echo "Deploy to ${SERVER_IP} complete."
