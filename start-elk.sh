#!/bin/bash

# GitHub Enterprise Cloud Webhook ELK Stack Startup Script

echo "🚀 Starting GitHub Enterprise Cloud Webhook ELK Stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ docker compose is not available. Please install Docker Compose and try again."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker compose down

# Build and start the stack
echo "🔨 Building and starting the ELK stack..."
docker compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check if Elasticsearch is ready
echo "🔍 Checking Elasticsearch status..."
if curl -s "http://localhost:9200/_cluster/health" > /dev/null; then
    echo "✅ Elasticsearch is ready at http://localhost:9200"
else
    echo "⚠️  Elasticsearch might still be starting up..."
fi

# Check if Kibana is ready
echo "🔍 Checking Kibana status..."
if curl -s "http://localhost:5601/api/status" > /dev/null; then
    echo "✅ Kibana is ready at http://localhost:5601"
else
    echo "⚠️  Kibana might still be starting up..."
fi

echo "📊 ELK Stack URLs:"
echo "   📈 Kibana Dashboard: http://localhost:5601"
echo "   🔍 Elasticsearch API: http://localhost:9200"
echo "   📥 Logstash Webhook Endpoint: http://localhost:8080"

echo ""
echo "📋 To test the webhook endpoint:"
echo "   curl -X POST http://localhost:8080 \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -H 'X-GitHub-Event: push' \\"
echo "     -H 'X-GitHub-Delivery: test-12345' \\"
echo "     -d @example-webhook.json"

echo ""
echo "📄 To view logs:"
echo "   docker compose logs -f logstash"
echo "   docker compose logs -f elasticsearch"
echo "   docker compose logs -f kibana"

echo ""
echo "🛑 To stop the stack:"
echo "   docker compose down"

echo ""
echo "✨ ELK Stack is starting up! Check the URLs above in a few minutes."
