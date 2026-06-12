#!/bin/bash
set -e

echo "========================================="
echo " ROLLBACK INITIATED"
echo " Rolling back to build: ${PREVIOUS_BUILD_NUMBER}"
echo " Server: ${SERVER_IP}"
echo "========================================="

SSH_OPTS="-o StrictHostKeyChecking=no -i ${SSH_PRIVATE_KEY}"

ssh ${SSH_OPTS} ${DEPLOY_USER}@${SERVER_IP} << ENDSSH
  set -e

  ROLLBACK_IMAGE="${DOCKER_IMAGE}:${PREVIOUS_BUILD_NUMBER}"

  echo "Pulling rollback image: \${ROLLBACK_IMAGE}"
  docker pull \${ROLLBACK_IMAGE}

  echo "Stopping failed container..."
  docker stop ${CONTAINER_NAME} 2>/dev/null || true
  docker rm ${CONTAINER_NAME} 2>/dev/null || true

  echo "Starting rollback container from \${ROLLBACK_IMAGE}..."
  docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${APP_PORT}:3000 \
    -e NODE_ENV=production \
    \${ROLLBACK_IMAGE}

  echo "Rollback container started."
  docker ps | grep ${CONTAINER_NAME}
ENDSSH

echo "Rollback to build #${PREVIOUS_BUILD_NUMBER} on ${SERVER_IP} complete."
