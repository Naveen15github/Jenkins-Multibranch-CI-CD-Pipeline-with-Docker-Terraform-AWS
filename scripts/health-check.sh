#!/bin/bash

HEALTH_URL="http://${SERVER_IP}:${APP_PORT}/health"
MAX_RETRIES=10
RETRY_INTERVAL=10
attempt=1

echo "Starting health check: ${HEALTH_URL}"

while [ $attempt -le $MAX_RETRIES ]; do
  echo "Attempt ${attempt}/${MAX_RETRIES}..."

  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${HEALTH_URL}" 2>/dev/null)

  if [ "${HTTP_STATUS}" == "200" ]; then
    BODY=$(curl -s --max-time 5 "${HEALTH_URL}")
    STATUS=$(echo "${BODY}" | grep -o '"status":"ok"' || true)

    if [ -n "${STATUS}" ]; then
      echo "Health check PASSED (HTTP 200, status: ok)"
      exit 0
    else
      echo "HTTP 200 received but status is not ok. Body: ${BODY}"
    fi
  else
    echo "Received HTTP status: ${HTTP_STATUS}"
  fi

  echo "Retrying in ${RETRY_INTERVAL} seconds..."
  sleep ${RETRY_INTERVAL}
  attempt=$((attempt + 1))
done

echo "Health check FAILED after ${MAX_RETRIES} attempts."
exit 1
