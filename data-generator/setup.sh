#!/bin/bash

set -e

KAFKA_HOST=${KAFKA_BROKER:-kafka:9092}
MAX_RETRIES=30
RETRY_INTERVAL=5

echo "Waiting for Kafka broker at $KAFKA_HOST..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  if echo > /dev/tcp/$(echo $KAFKA_HOST | cut -d: -f1)/$(echo $KAFKA_HOST | cut -d: -f2) 2>/dev/null; then
    echo "Kafka is available! Starting generator..."
    exec python3 generate_events.py
  else
    echo "Attempt $i/$MAX_RETRIES: Kafka not ready yet..."
    sleep $RETRY_INTERVAL
  fi
done

echo "Kafka did not become ready in time. Exiting."
exit 1
