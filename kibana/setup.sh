#!/bin/bash

# Start Kibana in background via tini wrapper
/bin/tini -- /usr/share/kibana/bin/kibana &

# Wait for Kibana to start
until curl -s http://localhost:5601/api/status | grep -q "overall"; do
  echo "Waiting for Kibana to start..."
  sleep 5
done

echo "Kibana is up"

# Wait for Elasticsearch to be ready
until curl -s http://elasticsearch:9200 | grep -q "cluster_name"; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

echo "Elasticsearch is up"

# Create index pattern for ctr_metrics
echo "Importing index patterns..."
curl -X POST "http://localhost:5601/api/saved_objects/index-pattern/ctr_metrics" \
  -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' \
  -d '{
    "attributes": {
      "title": "ctr_metrics",
      "timeFieldName": "window_start"
    }
  }'

# Import Kibana dashboard
echo "Importing Kibana dashboard..."
curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  --form file=@/opt/setup/dashboard.ndjson

# Keep the container running
wait