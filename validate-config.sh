#!/bin/bash

# Simple validation script for Logstash configuration
# This script checks basic syntax and structure

CONFIG_FILE="logstash.conf"

echo "Validating Logstash configuration: $CONFIG_FILE"

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Basic syntax checks
echo "✅ Configuration file exists"

# Check for required sections
if grep -q "^input {" "$CONFIG_FILE"; then
    echo "✅ Input section found"
else
    echo "❌ Input section missing"
    exit 1
fi

if grep -q "^filter {" "$CONFIG_FILE"; then
    echo "✅ Filter section found"
else
    echo "❌ Filter section missing"
    exit 1
fi

if grep -q "^output {" "$CONFIG_FILE"; then
    echo "✅ Output section found"
else
    echo "❌ Output section missing"
    exit 1
fi

# Check for balanced braces (basic check)
OPEN_BRACES=$(grep -o "{" "$CONFIG_FILE" | wc -l)
CLOSE_BRACES=$(grep -o "}" "$CONFIG_FILE" | wc -l)

if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
    echo "✅ Balanced braces ($OPEN_BRACES opening, $CLOSE_BRACES closing)"
else
    echo "❌ Unbalanced braces ($OPEN_BRACES opening, $CLOSE_BRACES closing)"
    exit 1
fi

# Check for HTTP input plugin
if grep -q "http {" "$CONFIG_FILE"; then
    echo "✅ HTTP input plugin configured"
else
    echo "❌ HTTP input plugin not found"
    exit 1
fi

echo ""
echo "🎉 Basic configuration validation passed!"
echo ""
echo "To test with real Logstash:"
echo "1. Install Logstash: https://www.elastic.co/guide/en/logstash/current/installing-logstash.html"
echo "2. Run: logstash --config.test_and_exit -f $CONFIG_FILE"
echo "3. If syntax is valid, run: logstash -f $CONFIG_FILE"
echo ""
echo "To test webhook reception:"
echo "curl -X POST http://localhost:8080 \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-GitHub-Event: push\" \\"
echo "  -H \"X-GitHub-Delivery: test-12345\" \\"
echo "  -d @example-webhook.json"