#!/bin/bash

# Wait for Kibana to be ready
echo "⏳ Waiting for Kibana to be ready..."
until curl -s "http://localhost:5601/api/status" > /dev/null; do
    echo "Waiting for Kibana..."
    sleep 5
done

echo "✅ Kibana is ready!"

# Create index pattern for GitHub webhooks
echo "📊 Creating GitHub webhooks index pattern..."
curl -X POST "http://localhost:5601/api/saved_objects/index-pattern/github-webhooks-*" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{
    "attributes": {
      "title": "github-webhooks-*",
      "timeFieldName": "@timestamp"
    }
  }'

echo ""
echo "✅ Index pattern created! You can now:"
echo "   1. Open Kibana at http://localhost:5601"
echo "   2. Go to Analytics > Discover"
echo "   3. Select the 'github-webhooks-*' index pattern"
echo "   4. Start exploring your GitHub webhook data!"

echo ""
echo "📊 Useful Kibana queries:"
echo "   - event_type:push (show only push events)"
echo "   - repo_name:\"your-repo-name\" (filter by repository)"
echo "   - sender_login:\"username\" (filter by user)"
echo "   - action:\"opened\" AND event_type:\"pull_request\" (new PRs)"
