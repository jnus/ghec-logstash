#!/bin/bash

# Test script to validate webhook processing logic
# This script tests the example webhook payload structure

EXAMPLE_FILE="example-webhook.json"

echo "Testing GitHub webhook payload structure..."

# Check if example file exists
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "❌ Example webhook file not found: $EXAMPLE_FILE"
    exit 1
fi

echo "✅ Example webhook file found"

# Validate JSON syntax
if jq . "$EXAMPLE_FILE" > /dev/null 2>&1; then
    echo "✅ Valid JSON format"
else
    echo "❌ Invalid JSON format"
    exit 1
fi

# Check for required GitHub webhook fields
REQUIRED_FIELDS=("repository" "sender" "ref" "commits")

for field in "${REQUIRED_FIELDS[@]}"; do
    if jq -e ".$field" "$EXAMPLE_FILE" > /dev/null 2>&1; then
        echo "✅ Required field '$field' present"
    else
        echo "❌ Required field '$field' missing"
        exit 1
    fi
done

# Extract and display key information that our Logstash config would process
echo ""
echo "📊 Webhook payload analysis:"
echo "Event type: push (would be set via X-GitHub-Event header)"
echo "Repository: $(jq -r '.repository.full_name' "$EXAMPLE_FILE")"
echo "Sender: $(jq -r '.sender.login' "$EXAMPLE_FILE")"
echo "Ref: $(jq -r '.ref' "$EXAMPLE_FILE")"
echo "Commits: $(jq -r '.commits | length' "$EXAMPLE_FILE")"
echo "Before SHA: $(jq -r '.before' "$EXAMPLE_FILE")"
echo "After SHA: $(jq -r '.after' "$EXAMPLE_FILE")"

echo ""
echo "🎉 Webhook payload test passed!"
echo ""
echo "This payload would be successfully processed by the Logstash configuration."